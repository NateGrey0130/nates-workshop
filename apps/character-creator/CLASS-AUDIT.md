# Character creator — class audit, 2026-08-25

> **Since 2026-09-16 the closed findings live in `CLASS-AUDIT.closed.md`**, moved
> there verbatim with their headings, numbering and notes; this file keeps a
> one-line pointer per moved finding where its heading was, and holds in full
> every finding whose own section records no outcome. The closed file is a
> record like this one, and the `*AUDIT*.md` glob reaches both.

> **All 29 items are closed**, re-verified on 2026-09-02: `F1`–`F20` and `S1`–`S9`.
>
> **The one that misreads:** the nine `S` items are **bullets**, not headings —
> `- **S1 — …**` under `## Schema-can-now-express`. A scan that walks `###`
> headings does not report them open; it does not see them at all, and nine
> items vanish with no error.

Read-only audit of every published class in production against the source
books. Verified against production D1 (`--remote`, per the repo's rule) as of
`main` @ `652cc4f`, baseline **109 published classes**, smoke suite green
(**1,306 checks in 86 sections**) before anything was read. No data, doc or
code was changed by this audit.

Method: every class's production markdown was pulled from `imported_classes`
and checked three ways — (1) parsed through the real parser and
cross-referenced against a production catalog snapshot (skills 333, spells 570,
psionics 101, gear 897, redirects 45); (2) its numeric fields (money, bonuses,
saves, pool bases, attribute requirements) compared line-by-line against the
book text — the `rue`/`pf` OCR caches for cached books, the PDFs' own text
layers for Juicer Uprising, Pantheons of the Megaverse, Dragons & Gods, Book of
Magic and the original Rifts core, all of which are on this machine; (3) its
notes swept for limitation claims and re-judged against the current schema.
Page numbers below are **printed** pages.

Findings are a menu: one PR per taken finding, `Taken` notes appended under
each as they land. Per the standing rule, zero related/secondary skills on an
R.C.C. was never flagged — those come from the paired O.C.C.

---

## Findings

- **F1** — high — Combat Cyborg has no skills, no equipment and no money, and the book prints all three — - Taken, 2026-08-25: `fix-combat-cyborg-full-block.sql`, as sketched — one — full text in `CLASS-AUDIT.closed.md` under its own `### F1` heading.

- **F2** — high — 20 gear rows were retired as "orphans" while nine live classes still cite them in choice groups — - Taken, 2026-08-25: `zzz-resolve-choice-group-gear.sql` (zzz- so a clean — full text in `CLASS-AUDIT.closed.md` under its own `### F2` heading.

- **F3** — high — Wilderness Scout's bonus block is wrong four ways, and one of them is silently ignored — - Taken, 2026-08-25: `fix-wilderness-scout-bonuses.sql`, as sketched — one — full text in `CLASS-AUDIT.closed.md` under its own `### F3` heading.

- **F4** — high — the Crazy heals like a Vagabond: 1D6 Hit Points where the book gives 5D6, and the +1D6 P.E. is gone — - Taken, 2026-08-25: `fix-crazy-super-endurance.sql`, as sketched — two — full text in `CLASS-AUDIT.closed.md` under its own `### F4` heading.

- **F5** — high — Cyber-Knight's combat block, attribute line and psionics all disagree with RUE — - Taken, 2026-08-26: `fix-rue-cyber-knight-bonuses.sql` — the sketch's — full text in `CLASS-AUDIT.closed.md` under its own `### F5` heading.

- **F6** — high — eight mage classes' P.P.E. and six psychics' I.S.P. drop the book's attribute term — - Taken, 2026-08-26: `fix-rue-pool-attribute-terms.sql` (the `rue-` — full text in `CLASS-AUDIT.closed.md` under its own `### F6` heading.

- **F7** — medium — Operator has no bonus block at all — - Taken, 2026-08-26: `fix-operator-bonuses.sql`, as sketched — one — full text in `CLASS-AUDIT.closed.md` under its own `### F7` heading.

- **F8** — medium — dropped Perception bonuses across eleven classes (the key exists and live classes use it) — - Taken, 2026-08-26: `fix-perception-bonuses.sql`, as sketched — the — full text in `CLASS-AUDIT.closed.md` under its own `### F8` heading.

- **F9** — medium — disease saves dropped or misattributed in six classes — - Taken, 2026-08-26: `fix-disease-saves.sql`, as sketched — body-fixer's — full text in `CLASS-AUDIT.closed.md` under its own `### F9` heading.

- **F10** — medium — three fail-open skill restrictions offer skills the book forbids — - Taken, 2026-08-26: `fix-misfiled-excepts.sql`, as sketched — Sensory — full text in `CLASS-AUDIT.closed.md` under its own `### F10` heading.

- **F11** — medium — four choice options resolve to no catalog row, so the pick fails — - Taken, 2026-08-26: `fix-broken-pick-options.sql`, as sketched — the — full text in `CLASS-AUDIT.closed.md` under its own `### F11` heading.

- **F12** — medium — Valkyrie's racial S.D.C. is an `sdc_base`, so an occupation's S.D.C. is silently lost — - Taken, 2026-08-26: `fix-valkyrie-sdc-pool.sql`, as sketched. The — full text in `CLASS-AUDIT.closed.md` under its own `### F12` heading.

- **F13** — medium — the Dragon Hatchling parent is missing its power schedule and its combat framework — - Taken, 2026-08-26: `fix-rifts-core-dragon-hatchling.sql` — the — full text in `CLASS-AUDIT.closed.md` under its own `### F13` heading.

- **F14** — medium — Juicer's "+2 to disarm" is missing, and three Juicer Uprising sub-classes copied the gap — - Taken, 2026-08-26: `fix-rue-juicer-disarm.sql` (the `rue-` infix so — full text in `CLASS-AUDIT.closed.md` under its own `### F14` heading.

- **F15** — medium — Knight (PF) has no bonus block — - Taken, 2026-08-26: `fix-knight-bonuses.sql`, as sketched — one — full text in `CLASS-AUDIT.closed.md` under its own `### F15` heading.

- **F16** — low — five classes are missing printed money, all verified against the page — - Taken, 2026-08-26: `fix-missing-starting-money.sql`, as sketched, with — full text in `CLASS-AUDIT.closed.md` under its own `### F16` heading.

- **F17** — low — missing attribute requirements in seven classes, and three page ranges end a page early — - Taken, 2026-08-26: `fix-rue-attr-reqs-and-ranges.sql` — smaller than — full text in `CLASS-AUDIT.closed.md` under its own `### F17` heading.

- **F18** — low — 39 classes have no page range in `source_book` at all, so the page-break defence cannot run on them — - Taken, 2026-08-26: `fix-source-book-pages.sql` — all forty stamped — full text in `CLASS-AUDIT.closed.md` under its own `### F18` heading.

- **F19** — low — Ley Line Walker and Rifter drop their attribute-of-choice bonus — - Taken, 2026-08-26: `fix-walker-rifter-attribute-choice.sql` — the — full text in `CLASS-AUDIT.closed.md` under its own `### F19` heading.

- **F20** — low — Vagabond's "+1 save vs possession **and psionic attacks**" lost the psionics half — - Taken, 2026-08-26: rode `fix-missing-starting-money.sql` (F16) as — full text in `CLASS-AUDIT.closed.md` under its own `### F20` heading.

## Verified clean

Every class was checked; "clean" below means every field examined matched the
book (or its deviation is documented in its own notes and still true). Classes
named in findings above are clean **outside** the cited fields.

**Tier 2 — RUE (cache-cited)**: all six dragon-hatchling RUE variants
(cats-eye, flame-wind, forest-runner, royal-frilled, snow-lizard, whip-tailed —
every M.D.C./S.D.C./P.P.E./I.S.P. base and full bonus block matched its stat
block), headhunter-techno-warrior (its at-level initiative/HF schedules are
the model the fixes above should copy), mind-melter (bonus block exact,
I.S.P. carries the M.E. term — proof of the convention), juicer (saves and
attributes), psi-stalker and wild-psi-stalker (saves, money, the documented
starting_money 0), burster (bonuses, named power list via `powers_from`),
glitter-boy (money 4D6x100 p.71; the lineage-conditional bonus storage is
documented), body-fixer (money), city-rat (pools), dog-boy (money = two
months' pay, documented), coalition-samas-pilot (money and the empty
page-break continuation), robot-pilot (money 1D6x100 p.85, attr reqs),
merc-soldier (money p.83), rogue-scholar and rogue-scientist and vagabond
(bonus blocks), cyber-doc (documented money omission), techno-wizard (magic
bonuses and at-level schedule), shifter and mystic (save schedules exact),
ley-line-walker and rifter (save schedules exact), crazy (everything outside
F4), elemental fusionists (bonuses outside F9/F17), wilderness-scout (money +
the p.100 page-break continuation), vagabond-peasant (120 gold, and its
page-break continuation is a chapter heading — clean).

**Tier 2 — PF Main Book races (cache-cited)**: human, elf, dwarf, gnome,
troglodyte, kobold, goblin, hob-goblin, orc, ogre, troll, changeling, wolfen,
coyle — **all fifteen race stat blocks match**, including every
S.D.C.-as-pool-bonus and the "+2 vs telepathic probes → psionics" reading.
The dwarf's "+1 vs magic" expanded across the five magic-save keys is a
consistent convention, noted, not flagged.

**Tier 2 — PF core O.C.C.s (located by hand in the pf cache)**: assassin,
diabolist, merchant, mercenary-fighter, mind-mage (money 150, saves +6/+5/+3
all at p.162), noble, palladin (full HF schedule exact), priest-of-darkness,
priest-of-light (money 150; its two dead W.P. restrictions are the documented
floor — **not** a finding), psi-mystic, psychic-sensitive, ranger, scholar,
soldier, squire, summoner (save schedule exact), thief, warrior-monk (the
disease-save fix held; stick-fighting bonuses correctly conditional prose),
witch (variants + documented trade-offs), wizard. Druid, knight, long-bowman,
psi-healer carry the findings above and are otherwise clean.

**Juicer Uprising ×15 (PDF text layer)**: hyperion, titan, phaeton, mega,
delphi, coalition-juicer, psycho-stalker, dragon-juicer, murder-wraith,
maxi-killer (its poison **and disease** both captured — the one class that got
it right), juicer-gladiator/assassin/scout (money bonuses match 1D4x1000 /
1D6x1000 / 2D6x10 at p.56-58; bonuses are deliberate copies of the standard
Juicer per their notes — F14 applies), gambler, juicer-wannabe. The money
audit and PR #294's page-break work show: nothing new found in money or
equipment across the whole book.

**Pantheons ×14 (PDF text layer)**: godling (incl. the 1d4 dice initiative
bonus), demigod (P.P.E./I.S.P. correctly modeled as +4d6 pool bonuses),
rifts-priest (money verified at p.15), scorpion-person, greater-cyclops,
naga, daitya, dakini, norse-giant (the three-random-abilities table is
documented prose), asgardian-dwarf, asgardian-high-elf, berserker
(rage bonuses correctly conditional prose; book "Money: None to start" —
an explicit `starting_money: "0"` would match wild-psi-stalker's convention,
info only), warrior-of-valhalla ("+2D6x10 S.D.C." correctly a pool bonus).
Valkyrie carries F12, otherwise clean.

**Dragons & Gods**: chiang-ku-dragon — both variants verified line-by-line
(hatchling P.P.E. 2D4x10+20 is **correct**; the neighbouring "2D4x10+40" on
the same page belongs to the Basilisk — a trap the next auditor should know).

**Book of Magic**: stone-master — attr reqs, money 6D6x1000, bonuses,
variant P.P.E. formulas all match p.224-225.

---

## Blocked: need book

- **warlock** — the Book of Magic holds only the Warlock's **spell lists**
  (which its p.66-70 citation correctly spans); the Rifts Warlock O.C.C. stat
  block itself is not in BOM (p.56 defers to the O.C.C.'s home book —
  Federation of Magic, not on this machine). Unverifiable against a book
  today: the bonus block, starting money, I.S.P., attribute requirements and
  the related-skill program. The recorded Palladium Fantasy deltas
  (`record-warlock-palladium-deltas.sql`) and the P.P.E. formulas were checked
  against the PF main book and the class's own prose (F6 covers the P.P.E.
  term). Supply the Federation of Magic O.C.C. pages to close it out.
- **Closed out, 2026-08-26** — and both of this note's book claims were
  wrong. Federation of Magic arrived (cached as `fom`, reader = printed+1;
  the copy is truncated at printed 72 of 176, mid Battle Magus) and its own
  printed p.7 defers: "As for Warlocks, Elemental Magic and Elementals, see
  Rifts Conversion Book (One)." BOM agrees with itself once read rather
  than remembered: its O.C.C. index (printed 24) reads "Warlock O.C.C.
  (Rifts Conversion Book One Revised, p. 66)", and BOM printed 66-70 —
  which this note called the warlock's spell lists — is actually **Earth
  spell descriptions, levels 1-5**. Conversion Book One Revised was already
  in Downloads; cached as `cb1` (200 pages, text layer, reader =
  printed+1). "The Warlock O.C.C." prints on folio 66 and every figure this
  note called unverifiable reads **verbatim** on printed 66-71: attribute
  requirements (both variants), the bonus line ("+2 to save vs Horror
  Factor (+6 against Elemental beings), +1 to save vs magic, and +1 to save
  vs possession. +1 to spell strength at levels 3, 6, 10 and 14" — the
  vs-magic +1 carried as the `spell_magic`/`ritual_magic` pair per repo
  convention), P.P.E. 2D4x10+20/+40 "in addition to the P.E. attribute
  number" +2D6/level, the full O.C.C. skill list with every bonus, the
  related-skill program (8, two from Wilderness or Domestic, +2 @3 and +1
  @6/9/12) with every category caveat, four secondary skills, and money
  "2D6x1000 in credits and 3D4x1000 in Black Market items" (printed 71).
  There is no I.S.P. to verify — the class has none, correctly. The one
  defect was the stamp: the class was evidently imported FROM CB1 with the
  pages right and the book name wrong. `zzz-warlock-home-book.sql` moves it
  to `Rifts Conversion Book One p.66-71` (the money page included) and
  rewrites the two in-class notes that repeated the wrong title (the `zzz-`
  name sorts after `record-warlock-palladium-deltas.sql`,
  `zz-pf-experience-tables.sql` and `zzz-resolve-choice-group-gear.sql`,
  the later writers of this markdown). `--field-sources` now resolves
  `cb1` and walks exactly the Warlock's pages. The only observed
  adaptation, not changed: the book's sidearm is "automatic pistol or
  Triax pump weapon"; the class offers the app's standard energy-pistol
  choices plus the Triax stub.

Everything else was verifiable — every source book classes cite is now on
this machine and cached (rue, pf, bom, potm, dag, cb1, fom).

---

## Schema-can-now-express — the Step 3 review

Limitation notes swept from all 109 classes' markdown and re-judged against
the current parser/validator. **Now false** (each is a candidate data
migration; the note rewrite belongs in the same PR as its fix, per the
claim-audit rule):

- **S1 — Elemental Fusionists: "Elemental spells are not yet in the spell
  catalog, so record picks by hand."** False — `add-elemental-spells.sql`
  landed; the snapshot holds the `Air:`/`Earth:`/`Fire:`/`Water:` rows.
  Migration: real `magic` blocks (`spells_starting: 1` +
  `spells_per_level_from:` the orientation lists — the shifter's shape), notes
  rewritten. The biggest single mechanic currently held in prose.
  - **Taken, 2026-08-26** (`fix-rue-elemental-fusionist-spells.sql`, plus the
    app change below): both orientations carry real `magic` blocks now —
    `spells_starting: 1` bounded by `spells_from`, and a `spells_schedule`
    entry at every level from 2 to 15 drawing `from_list`, the shifter's shape
    with the starting pick bounded too. Verified in the running wizard: a
    level-one Earth/Air Fusionist is offered **exactly its eighteen**, and a
    level-4 Fire/Water one is offered "1 spell from a list of 19" at each of
    levels 2, 3 and 4.
    **The sketch could not have been done as data.** `spells_starting: 1` alone
    would have let a first-level Fusionist pick any of the catalog's ~570
    spells, eighth-level warlock magic included — strictly worse than the prose
    it replaced. The creation builder took **one count and one gate**, and
    `validate-character.js` hardcoded `from: null` on the starting spell pool:
    psionics has had `powers_from` since the burster, spells never got the
    twin. So `magic.spells_from` is new, and it arrived with the S9 shape in
    one change (`startingGroups` in `js/leveling.js`, read by the wizard *and*
    the server — the two builders are the pair that drifts).
    **Every name was checked on its printed P.P.E., not just on its name.** All
    36 book names resolve and all 36 costs match their catalog row. Two the
    name alone would have missed: the book's "Thunder Clap" is stored as
    `Air: Thunderclap`, and the book prints one undivided list per orientation
    while the catalog files each spell under its own element (Chameleon is
    Earth, Create Light is Air).
    **One name is ambiguous and is deliberately left so.** The Fire/Water list
    prints "Cloud of Steam (10)" untagged, and the catalog holds two rows of
    that name **both at 10 P.P.E.** — `Fire: Cloud of Steam` (level 4) and
    `Water: Cloud of Steam` (level 1). Nothing in the entry separates them and
    the element counts do not either, so **both** are on the list: a pick costs
    one slot whichever is taken, so offering both forbids nothing the book
    grants and invents no spell it does not name, where guessing would have
    buried a coin flip where nothing would ever flag it. That is why the
    Fire/Water list is 19 names for 18 printed ones.
- **S2 — Cyber-Knight: "The 80% chance of having psionics at all is a
  per-character roll the class schema cannot state."** False —
  `psionics_allowed` rolled tiers exist (`rollsForPsionics`, wizard briefing,
  smoke-pinned). Its second note, "psionics gates by category rather than by
  name", is also false — `powers_from` exists (burster). Migration: model the
  d100 tiers and the named nine-power list; pairs with F5.
  - **Partly taken, 2026-08-26** (`fix-rue-cyber-knight-psionics.sql`): the
    second half of the finding is right and is now data; the first half is
    wrong, and the wrong half is the one that mattered.
    **It also found a live error F5 introduced.** F5 set `powers_starting: 9`,
    reading the book's "three powers known to all Cyber-Knights" as three of
    the picks plus the Major band's six. **That could never work.** The three
    are Create Psi-Sword, Create Psi-Shield and Meditation, and the catalog
    files the first two under **Super** — a category a major psychic cannot
    reach. So the nine picks were nine Healing/Sensitive/Physical powers,
    *three more than the book grants*, and the universal three were
    unreachable. Now `powers: ["Psi-Sword", "Psi-Shield", "Meditation"]`
    granted by name, `powers_starting: 6`, and
    `categories_allowed: ["Healing", "Sensitive", "Physical"]` stated instead
    of left open. Granted powers are exempt from the category and tier gates
    server-side, by design, so the Super pair lands correctly.
    **The d100 table stays unmodelled, and the finding's reason for thinking
    it needn't is the error.** `psionics_allowed` rolled tiers are **one
    global table**, hardcoded in `js/psionics.js` from Palladium Fantasy 2nd
    Ed. p.20-21 (01-09 major, 10-25 minor, 26-00 none), and
    `rollsForPsionics()` returns false for any class declaring a `psionics`
    block at all. There is **no per-class rolled-table shape**. This one needs
    four bands (01-40 minor / 41-60 major / 61-70 master / 71-00 non-psychic)
    carrying four I.S.P. bases, four power counts, two save targets, and the
    master band's Super-psionic schedule *and* Psi-Sword damage schedule. That
    is an app change, and a larger one than S1's.
    **`powers_from` does exist — and does not apply here.** The finding is
    right that the "gates by category rather than by name" note was false. But
    the named list is the **minor** band's, and this class is stored as Major,
    which draws from the three categories. So the correction is recorded in
    the note rather than spent on the wrong tier.
    Two book errors came out with it, both re-read from the cache (rue p067 =
    printed 64, the cache running printed+3): the book says about **seventy**
    percent are psychic, not eighty — 71-00 is the non-psychic band — and the
    minor band's list holds **twelve** names, not the nine the class carried;
    the missing three (Alter Aura, Resist Fatigue, Total Recall) are the
    original core book's omissions, and all twelve are in the catalog. The
    whole table is now in the ability's prose, where it has to live until the
    app can hold one. Simulated against live markdown: `class-check` ready,
    0 errors, 0 warnings.
- **S3 — "no bonus key" notes falsified by `perception`/`disarm`:** burster
  ("+1 Perception has no bonus key and sits in restrictions"), juicer ("+2
  Perception, +2 disarm … have no bonus key"), ley-line-walker ("neither
  spell strength nor perception is a [key]" — half false),
  ley-line-rifter/headhunter ("applied by hand"). Fixed by F8/F14 plus note
  rewrites.
  - **Taken, 2026-08-26** (`fix-rue-ley-line-walker-perception.sql`): four of
    the five were already done and the fifth was the whole item. Read from D1
    rather than from the `add-*` scripts: burster, juicer and
    headhunter-techno-warrior carry their perception (and the juicer its
    disarm) with their notes rewritten, by F8 and F14; ley-line-rifter the
    same. Only **ley-line-walker** was left, and F8 skipped it on purpose —
    its bonus is a *schedule*, "+1 on Perception Rolls at levels 2, 5, 7, 10,
    and 13; double when on a ley line" (re-read from the cache, rue p119), not
    a flat number. It lands as five `at_level` `combat.perception` entries and
    **no base `combat` block**: the schedule starts at level 2, so a base
    `perception: 1` — the mystic's shape, which F8 *did* use — would hand every
    walker a point the book never gives. The doubling stays prose, correctly:
    `bonuses` is unconditional. The rewritten note also corrects a second false
    sentence in the same paragraph, that the "+3 to save vs curses" is carried
    `at_level`; it is flat, and has been since `fix-ley-line-walker-rue-bonuses`
    established that the leveled save is the *magic* save.
    **The filename is the finding worth keeping.** The obvious
    `fix-ley-line-walker-perception.sql` sorts *before* both
    `fix-ley-line-walker-rue-bonuses.sql` (which rewrites the `at_level` block
    it appends to) and `fix-pre-rue-class-audit.sql` (which rewrites this
    class's whole markdown), so on a clean rebuild it would find neither anchor
    and silently do nothing — live D1 would be right and a rebuilt database
    wrong. The `fix-rue-` infix puts it after both, the same trick F14 used.
    Verified by simulating both `replace()` pairs against the live markdown:
    `class-check` reads ready, 0 errors, 0 warnings.
- **S4 — Godling: the extraction note says the category bonuses "(Domestic
  +10%, Medical +10%, Technical +10%, Wilderness +5%) have nowhere to go in
  the format and are not applied", and that Horsemanship is "offered as a
  category without the bonus".** Both false in the same file: the data above
  the note carries `bonus: 10/10/10/5` **and** `Horsemanship bonus: 15`. Pure
  note rot — rewrite only, no data change.
  - **Taken, 2026-08-26** (`fix-godling-skill-category-bonuses-note.sql`): as
    written — one statement, no data touched, and the readback asserts all five
    bonuses are still present so that "no data change" is proved rather than
    claimed. The bonuses arrived in `fix-godling-demigod-accuracy.sql`'s F3,
    which rewrote no note, so the class carried the bonuses *and* a paragraph
    swearing it could not: the data right and the only prose about it wrong,
    which is worse than either alone.
    **Two things this took to see, both worth the next reader's time.** The
    original `add-godling-class.sql` still shows the pre-fix state, so reading
    it says the bonuses are absent and the note is *true* — only the database
    says otherwise, exactly as the class-import skill warns. And `instr` for the
    note's own sentence returns 0, because the stored text wraps mid-phrase
    (`have nowhere to` / newline / `go in the format`), which is why it survived
    earlier sweeps. Match a stored note across the wrap or it reads as gone.
- **S5 — Walker/Rifter attribute-of-choice "by hand"** — expressible via
  ability choice groups; taken as F19.
  - **Closed, 2026-08-26** — no work of its own; verified rather than assumed.
    F19 shipped `fix-walker-rifter-attribute-choice.sql` (the rifter half; the
    walker already carried its choose-1 group). Live `--remote` confirms both
    now hold a choice group, and the rifter's surviving "attribute of choice"
    phrase is the *rewritten* note saying it IS one — it cites this audit's F19
    by name. Spell Strength stays prose there, correctly: no such bonus key
    exists, which this file's own "Checked and still true" list records.
- **S6 — Witch: the Gift of Power's four-from-eleven "would need bonuses the
  shape cannot express together."** Partially false — an ability may now
  carry `bonuses` + `psionics` + `magic` together (ABILITY_GRANTS), which
  covers most of the eleven; flight and the impervious set stay prose. The
  Gift of Magic's spell allotment stays blocked (variants still cannot carry
  `magic` — verified). Modeling the eleven is a real project; user's call.
  - **Taken, 2026-08-26** (`fix-witch-gift-of-power-abilities.sql`): eleven
    ability definitions and a `{ choose: 4 }` over them, replacing the single
    prose ability. **Seven carry real bonuses**; four stay prose for one reason
    each — an immunity (not a save bonus), a constant sense, a flight Spd that
    applies only while flying, and a healing rate. "A real project" turned out
    to be one data script: the machinery was already there and validated.
    **The Sixth Sense grant is deliberately left prose**, and that is the one
    judgement call. An ability-level `psionics` block *replaces* the character's
    block rather than merging into it, and this class has none, so granting it
    would install a block with no `type` — inventing a psychic tier the book
    never states, on a class whose I.S.P. can arrive from a different gift. The
    saves that ability grants are modelled; only the power is not.
    **It also closed a live hole.** The `gift-of-power` variant carried
    `ppe_base: "2d4x10+20, but only if the P.P.E. ability is one of the four
    selected; otherwise none"` — a *condition inside a field that holds a dice
    formula*, which `leveling.js` feeds straight to `perLevelDiceOf`. It could
    never be enforced. The P.P.E. now rides on the pick and the variant states
    no base; with no top-level `ppe_base`, a witch who skips that gift correctly
    has none. Verified: rebuilt markdown runs `class-check` at 0 errors,
    0 warnings, and all seven bonus blocks read back.
- **S7 — Dog Boy: breed bonuses "are player options that no schema field
  holds."** `variants` override `bonuses` now — twenty breeds as variants is
  expressible, if bulky. User's call.
  - **Declined, 2026-08-26**, on Nate's word, and the finding above is wrong in
    two ways worth correcting in place rather than deleting.
    **It is five breeds, not twenty.** The stored table holds Irish Water
    Spaniel, Wolfhound, Irish/English Setters, Coonhound and Golden Retriever —
    and the book calls it *"a sample"*, covering percentile **01-25% only**
    before pointing at Rifts World Book 13: Lone Star pp.22-55 for the rest. So
    modelling it yields a percentile table that cannot be rolled on.
    **And every one of the five carries something `variants` provably cannot
    express** — the swim percentages (90%/55%/80%) and, worse, the Wolfhound's
    **-40%** and the Coonhound's **+5% to track by smell**. Both blockers are on
    this file's own *"Checked and still true"* list: `variants` cannot override
    `skills`, and no race-level per-skill modifier exists. Tracking by smell is
    the whole point of a Dog Boy, so a Coonhound modelled as "+3 Perception"
    with its tracking bonus dropped is **worse than the current prose, because
    it looks complete.** Two lesser objections: the table is explicitly
    *optional*, so variants would force every Dog Boy to choose a breed
    structurally; and `dog-boy` has no `variants` block today.
    **The real blocker is the missing per-skill modifier**, which also blocks
    changeling +5% Disguise, the gnome's list and kobold metalworking on the
    same list. Build that and this item plus several others unblock together;
    until then this buys a half-modelled table that hides its own gaps.
- **S8 — Goblin: the Cobbler sub-race "the app cannot express one yet."**
  Half false — a variant carries its `ppe_base` (3D4x10+1D6/level) and save
  bonuses; its faerie-magic spell grants still don't fit (no `magic` on
  variants).
  - **Taken, 2026-08-26** (`fix-goblin-cobbler-note.sql`): **as a note rewrite
    only — the Cobbler stays unimported, and no mechanic is touched.** The
    finding is right that the claim is half false, and the honest correction
    is to say *which* half. `VARIANT_OVERRIDES` now admits `attribute_dice`,
    `attribute_requirements`, `hit_points_base`, `sdc_base`, `mdc_base`,
    `ppe_base`, `starting_money`, `bonuses` and `skill_overrides` — so the
    Cobbler's 3D4x10+1D6/level P.P.E. and its three saves would fit. **Five of
    its seven parts still would not**: metamorphosis at will
    (`natural_abilities`), the six faerie spells (a `magic` block), the 1-15
    percentile roll, the major/master psionic exclusion (`psionics_allowed` is
    class-level), and the +10% to carpentry/boat building/whittling —
    `skill_overrides` may only restate a skill the class already grants, and
    this R.C.C. **grants none at all**, which is the same missing per-skill
    modifier this file's own "still true" list records for the changeling, the
    gnome and the kobold.
    So building the expressible half buys a Cobbler with a mage's P.P.E., no
    spells to spend it on and no metamorphosis — **S7's objection exactly**,
    and the reason this is a rewrite rather than a variant. The note now also
    records the trap that would catch whoever tries it: a variant's `bonuses`
    **replace** the class's rather than merging (`VARIANT_MERGED` is only the
    two attribute maps), so stating the Cobbler's three saves would silently
    drop the goblin's own +1 vs faerie magic and its S.D.C. pool bonus.
    **The route that would work is a second class**, `goblin-cobbler`, which
    can carry the abilities and the magic block. That is an import decision,
    not a transcription, and it is Nate's — the note says so instead of
    implying the app is at fault.
    Two smaller corrections rode along, both verified: the entry is printed
    **300**, not 302 (pf cache p302, footer 300, the printed+2 offset F18
    established), and the book's "his abilities do not increase as he gains
    new levels" was missing from the summary. Simulated against live markdown:
    `class-check` ready, 0 errors, 0 warnings.
- **S9 — Delphi Juicer / Mind Mage: per-category starting-power splits
  ("3 Physical + 1 Super", "three from each of four").** `powers_schedule`
  entries carry `categories` (mystic's level-4/8 Super picks) — whether a
  level-1 schedule entry fires at creation needs a check before calling this
  expressible; flagged for a look rather than asserted.
  - **Checked, 2026-08-26 — the answer is no, and it is worse than the finding
    supposed.** A level-1 `powers_schedule` entry does **not** fire at creation.
    `powers_schedule` is read only by `perLevelGrants` and
    `psionicCategoriesForGrant`, both of which run over a *fromLevel to toLevel*
    span — level-up only. Creation is built somewhere else entirely, and twice:
    `psiConfig` in `app.js` and `validate-character.js` on the server both
    assemble the starting pick from `powers_starting` (one count) plus
    `categories_allowed` **or** `powers_from`. One count, one category list. A
    per-category split at creation cannot be said.
    **Both named classes are therefore wrong in production right now**, which
    the finding did not claim: `delphi-juicer` carries `powers_starting: 4` with
    `categories_allowed: ["Physical", "Super"]` where the book grants *3 Physical
    + 1 Super*, so a player may legally take four Super; `mind-mage` carries
    `powers_starting: 12` over four categories where the book grants *three from
    each*, so a player may take twelve Super. The picker permits starting
    loadouts the books forbid.
    **The fix is smaller than it looks, and it is app code rather than data.**
    The server already assembles `pool.psionic` as an ARRAY of pick-groups
    (`[startPsi, ...grants]`), so everything downstream of the builders already
    handles several groups with different category gates. What is missing is a
    frontmatter shape letting `powers_starting` express more than one group, and
    the two builders reading it — the client and the server, which are separate
    paths and must move together. Until then the two classes should not be
    "corrected" by narrowing `categories_allowed`: that would trade a loadout
    that is too permissive for one that forbids a category the book grants.
    **A decision, not a defect to sweep up** — it needs the schema change, so it
    is Nate's call whether to build it.
  - **Built, 2026-08-26** (`zz-starting-power-splits.sql`, plus the app change
    it shares with S1) — on Nate's word, and it turned out to be the same
    change S1 needed rather than a second one. `startingGroups(cls, kind)` in
    `js/leveling.js` returns the starting picks as an **array** shaped exactly
    like `powerGrantsFor`'s level-up grants, and **both** builders read it: the
    wizard's Powers step and `validate-character.js`. Everything downstream
    already handled several groups with different gates — that is what the
    level-up grants are — so only the two builders had to move, which is the
    "smaller than it looks" the check above predicted.
    `powers_starting` keeps its meaning as the **total**, so every class
    stating only a number is untouched; `powers_starting_groups` splits it. A
    group naming its own categories replaces the block's, a group naming none
    inherits — the rule level-up grants already follow, because a book naming
    Super for one slot is granting an exception and intersecting would throw it
    away. `magic.spells_from` and `spells_starting_groups` are the same shape
    on the spell side; S1 needed the first of those.
    Both classes now say what their books say: `delphi-juicer` 3 Physical +
    1 Super, `mind-mage` three from each of four. **Verified in the running
    wizard**: picking one Super power on the Delphi disables the other 32 Super
    rows while all 22 Physical stay open, and the header counts 4/4 across the
    two groups. The loadout the flat count allowed — four Super, twelve Super —
    is now unreachable rather than merely undocumented.
    **The Mind Mage's page was re-read** (pf cache p163, footer 161): "three
    powers from each of the four psionic power categories: healing, sensitive,
    physical and Super (12 psi-powers total)". **The Delphi Juicer's could
    not** — Rifts World Book 10 has no OCR cache on this machine, and the book
    caches are local-only by design; its 3/1 split rests on two independent
    in-class records written from the page at import, which agree with each
    other and with this audit. Worth a page check if that book is cached again.
    **Two per-level progressions are still prose, and neither is blocked.** The
    Delphi's one-a-level from Physical/Sensitive/Super and the Mind Mage's
    five-a-level (two lesser + three Super) both fit `powers_schedule`, which
    carries per-entry categories and admits several entries at one level. Both
    classes' notes said they were prose *because the app could not hold them*;
    that reason was false even before this change and is corrected in the same
    script. They are simply not written — the Mind Mage's is now the larger
    remaining gap in that class.

**Checked and still true** (do not "fix" these — each was verified against
the current code): `variants` cannot override `skills`, `natural_abilities`,
`special_abilities`, `magic` or `psionics` (berserker, daitya, hatchling
variants, witch); spell schedules cannot hold dice-valued counts (RUE
hatchlings' 2D4+2); `occ_related_skills` cannot span a constraint across two
categories (assassin, juicer-wannabe, merc-soldier's either/or groups); no
race-level per-skill modifier exists (changeling +5% Disguise, gnome's +5%
list, kobold metalworking, asgardian-dwarf aptitude); no Spell Strength key
(walker/rifter/mystic/shifter schedules); the Diabolist's ward system and the
Juicer Wannabe's mid-campaign conversion remain out of scope; mind-mage's
P.C.C. category note stands; conditional bonuses (rage, in-armor, underwater,
drug-dependent, helmet-dependent) correctly live in prose throughout.

**Adjusted 2026-09-04 — one entry of the eight above is partly stale, and the
other seven were re-checked and hold.** Nate released the entry for correction;
the original sentence is left standing above because this file is a record.

**`occ_related_skills` cannot span a constraint across two categories** — the
entry, and what is now true of each example it names:

- **`assassin` — FALSE.** Its rule is two Espionage, two Rogue-or-Physical and
  five free (Palladium Fantasy printed 95, `pf` cache `p097`). That is one
  single-category floor plus one **union** floor, and
  `occ_related_skills.minimums` takes both. Fixed by `RETRO-AUDIT` `R13`
  (`zzzzz-retro-r13-assassin-minimums.sql`), which is also where the numbers and
  the enforcement posture are recorded.
- **`juicer-wannabe` — never an instance.** It carries two *independent
  single-category* floors, two Rogue and two Physical, which is an AND of two
  simple floors rather than a span. `RETRO-AUDIT` `R1` gave it those on
  2026-09-04.
- **`merc-soldier` — STILL TRUE, and mis-filed here.** Its either/or is *"two
  W.P.s of choice, OR two Demolition skills"*, which does span two categories —
  all three Demolition rows are `category = Military` and W.P.s are
  `Weapon Proficiencies`, checked against production on 2026-09-04 with
  `node scripts/q.mjs --remote "SELECT name, category FROM skills WHERE lower(name) LIKE '%demolition%'"`.
  It is still not expressible for two reasons: it is an **exclusive** or, and a
  union floor would permit one of each, which the book forbids; and it lives in
  a `mos` option, where `minimums` does not exist at all. It was filed under
  `occ_related_skills` in this list, which is the wrong block.

**So the entry should be read as: a *span* is expressible now; an *exclusive
choice between two groups* is not.** `RETRO-AUDIT` `R11`'s outcome note called
the merc-soldier *"entirely within one category"* — that is wrong, and is
corrected in `RETRO-AUDIT.md` as well as here.

**The other seven entries were each re-checked against the code on 2026-09-04
and all hold**, which is the half that makes this list worth keeping: `variants`
still cannot override those five keys (`VARIANT_OVERRIDES` in
`apps/character-creator/js/parser.js`); a spell schedule still degrades a
dice-valued count to 1 silently (`perLevelGrants` in
`apps/character-creator/js/leveling.js`); there is still no race-level per-skill
modifier and no Spell Strength key anywhere in `apps/character-creator/` or
`functions/`; the Diabolist's wards, the Juicer Wannabe's conversion and the
mind-mage's P.C.C. note all stand.

**One caveat on the eighth, stated rather than resolved.** *"Conditional bonuses
… correctly live in prose throughout"* holds **at class level** — a class's
`bonuses` has no conditional form. It does **not** hold for catalog **skill**
rows, where `level_bonuses` entries take `applies_when`; `RETRO-AUDIT` `R4`
moved seven of them on 2026-09-04. Whether *"throughout"* was ever meant to cover
skill rows is a wording judgement, so the entry is annotated rather than changed.

**Two entries were never verifiable "against the current code" as the lead-in
claims** — the Diabolist/Wannabe scope decision and the mind-mage's P.C.C. note
are decisions, not capability checks. True today either way.

---

## Recurring shapes worth a structural answer

1. **The excerpt trap** (F1): classes imported from partial page sets carry
   notes saying "the book doesn't state X" when only the excerpt didn't.
   F18's page ranges + a `--field-sources` pass over every class would have
   caught both F1 and F17's short ranges.
2. **Reference-integrity fails open** (F2, F10, F11): gear retirement, catalog
   category placement and pick-option naming all fail silently. One smoke
   check parsing every published class's referenced gear slugs, restriction
   names and enumerated pick options against the live catalogs would pin all
   three families permanently.
3. **The attribute-term convention drift** (F6): early imports and late
   imports disagree about whether the pool base carries the attribute term.
   After F6 lands, a one-line smoke grep (`ppe_base`/`isp_base` containing a
   bare `NdNx10` with the class prose mentioning "attribute number") keeps it
   from re-diverging.
