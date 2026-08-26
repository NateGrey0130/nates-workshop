# Character creator — class audit, 2026-08-25

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

### F1 — high — Combat Cyborg has no skills, no equipment and no money, and the book prints all three

- **Class**: `combat-cyborg` (Rifts Ultimate Edition, declared p.45-47)
- **Book says**: RUE printed **p.48** carries the full O.C.C. stat block the
  class lacks: `O.C.C. Skills:` (a real list), `O.C.C. Related Skills: Select
  five other skills at level one, +1 addi-…`, `Secondary Skills: Four Secondary
  Skills at level one … +1 additional…`, `Standard Equipment: Poncho or hooded
  cloak, tinted goggles or sun-…`, and `Money: Starts with 1D4x1,000 in
  credits/cash and 4D4x100 in sale[able]…`. The book also prints (p.47) the
  'Borg save bonuses as "**+5** bonus to save vs **possession**, **+3** bonus
  to save vs **magic**, and are impervious to psionic Telemechanics (all)".
- **Production says**: no `skills` block at all, no `equipment_starting`, no
  `starting_money`; `saves: { spell_magic: 5, ritual_magic: 5, psionics: 3 }` —
  the +5 landed on the wrong save (possession → magic) and the +3 on the wrong
  one too (magic → psionics). The extraction note says "No occ_skills …
  starting_money … is given anywhere **in the excerpt**" — true of the excerpt
  it was imported from, false of the book, whose full text is now in the `rue`
  cache. A character built from this class gets **zero occupational skills**.
- **Fix sketch**: `fix-combat-cyborg-full-block.sql` — re-transcribe printed
  p.47-48 into the markdown via guarded `replace()`: skills block, related
  (5 + schedule) and secondary (4 + schedule) programs, equipment list,
  `starting_money: "1d4x1000"`, saves rewritten to
  `{ possession: 5, spell_magic: 3, ritual_magic: 3 }` plus the Telemechanics
  immunity as prose, `source_book` widened to p.45-48, and the stale excerpt
  note rewritten. Run `class-check --field-sources` on the result.
- **Taken, 2026-08-25**: `fix-combat-cyborg-full-block.sql`, as sketched — one
  guarded whole-markdown `SET` (the chiang-ku shape), guarded on the old saves
  line with `instr()` rather than `LIKE` (D1 rejected the brace-heavy pattern
  as "too complex", and `spell_magic`'s underscore is a LIKE wildcard anyway).
  Skills at catalog base + printed bonus; the Pilot pick's robot exclusion and
  the ancient/modern W.P. splits ride in notes; Starting Extras and the
  4D4x100 in saleable items stay prose. `class-check --remote` clean,
  `--field-sources` shows the Money paragraph ending mid-page (no page-break
  splice). Verified byte-identical on local D1 before the PR.

### F2 — high — 20 gear rows were retired as "orphans" while nine live classes still cite them in choice groups

- **Classes**: `glitter-boy`, `ley-line-walker`, `ley-line-rifter`,
  `mind-melter`, `dog-boy`, `techno-wizard`, `warlock`, `priest-of-light`
  (and `mystic`'s vehicle list overlaps).
- **What happened**: `retire-orphan-gear-stubs.sql` (2026-08-19) deleted 33
  stub rows guarded on "no class markdown names the slug" — but the guard
  pattern was `instr(markdown, 'item_id: "slug"')`, which matches only FIXED
  entries. Choice groups cite slugs inside `from: ["…"]`, the guard never saw
  them, and the classes citing them had been imported the day before
  (#92, #94). Production today, cross-referenced against the live gear table
  (redirects consulted), is missing:
  - glitter-boy: `urban-warrior-armor`, `rifle`, `automatic-pistol`
  - ley-line-walker / ley-line-rifter: `automatic-pistol`
  - mind-melter: `rifle`, `automatic-pistol`, `hover-vehicle`, `robot-horse`,
    `jet-pack`, `motorcycle`, `car`, `techno-wizard-vehicle`
  - dog-boy: `c-10-laser-rifle`, `c-12-laser-rifle`
  - techno-wizard: `tw-wing-board`, `tw-tree-trimmer`
  - warlock: `triax-pump-weapon`
  - priest-of-light: `staff`, `blunt-weapon`, `chain-weapon`, `spear`, `sword`
- **Impact**: a wizard pick of one of these options resolves to nothing — the
  item lands as a bare custom line with no stats (the exact failure
  catalog-redirects.js exists to prevent). No redirect covers any of them.
- **Fix sketch**: two-part. (a) Real products (`c-10-laser-rifle`,
  `c-12-laser-rifle`, `tw-wing-board`, `tw-tree-trimmer`,
  `urban-warrior-armor`, `triax-pump-weapon`) — re-import proper rows from
  their book entries. (b) Category placeholders (`rifle`, `automatic-pistol`,
  `car`, `staff`, `sword`, …) — rewrite each citing choice to enumerate real
  catalog slugs, exactly as `retire-gear-placeholders.sql` did for the Juicer's
  `energy-pistol` (priest-of-light's five map to existing PF weapon rows:
  quarterstaff, mace/club, mace-and-chain/flail, short-spear/long-spear,
  short-sword/long-sword…). Also worth taking: a one-line smoke check that
  parses every published class's `referencedGear()` against the gear table, so
  a future retire/rename can never fail open this way again.
- **Taken, 2026-08-25**: `zzz-resolve-choice-group-gear.sql` (zzz- so a clean
  rebuild runs it after the retire script, which would otherwise delete the
  restored stub again). (a) C-10 and C-12 re-imported from RUE printed
  p.257-258, TW Wing Board and Tree Trimmer from printed p.136-137;
  `triax-pump-weapon` returns as a STUB because its stats are in Triax & The
  NGR, which is not on this machine (the citation is Conversion Book One's
  Warlock equipment); `urban-warrior-armor` was NOT re-imported — the suit
  already exists as `urban-warrior-padded-environmental-body-armor`, so the
  glitter-boy's choice is repointed at it instead. (b) Five classes rewired:
  priest-of-light's five families become ten PF rows (two per family), the
  mind-melter's vehicle list becomes eight real vehicles (no robot horse
  exists anywhere on this machine, so that option waits for an import), and
  the three conventional-firearm choices shrink to `["submachine-gun"]`, the
  only conventional firearm row — widen when such a book lands. The mystic
  cites nothing broken in production today, so nine classes proved to be
  eight. Smoke gained a `Gear citations resolve` section that parses every
  published class from the shared local DB and resolves `referencedGear()` —
  choice lists included — against gear + redirects (1310 checks / 87
  sections); README clean-run gear count 897 -> 902.

### F3 — high — Wilderness Scout's bonus block is wrong four ways, and one of them is silently ignored

- **Class**: `wilderness-scout` (RUE p.98-100)
- **Book says** (p.99): "+3D6+10 to physical S.D.C., +1D4 to P.S. and P.E.,
  +1 on initiative, +3 on Perception Rolls, +2 to roll with impact, **+2 to
  save vs poison and disease**, +10% to save vs Coma & Death, and **+1 to save
  vs Horror Factor at levels 2, 4, 6, 9, 12 and 15**."
- **Production says**: `bonuses.sdc: "3d6+10"` — `sdc` is not a recognised
  bonus group, the parser warns and **ignores it**, so the S.D.C. never
  reaches a sheet; `toxins_poisons: 10` (book: 2 — the 10 belongs to
  coma/death, which is separately correct); no `disease`; no `perception`;
  `horror_factor: 1` flat (book: an at-level schedule starting at 2).
- **Fix sketch**: `fix-wilderness-scout-bonuses.sql` — move the S.D.C. into
  `pools: { sdc: "3d6+10" }`, saves to
  `{ toxins_poisons: 2, disease: 2, coma_death_pct: 10 }`, add
  `perception: 3`, replace the flat HF with
  `at_level: [{level:2…},{4},{6},{9},{12},{15}]` (headhunter is the shape to
  copy). This is the third page-break/bonus defect on this class — worth a
  smoke case pinning the whole block.
- **Taken, 2026-08-25**: `fix-wilderness-scout-bonuses.sql`, as sketched — one
  guarded three-line replace spliced with `char(10)`, headhunter's `at_level`
  shape, the correct attributes line left alone. The name sorts before
  `fix-wilderness-scout-page-break.sql` and that is safe: the two edits touch
  different regions (page-break folded equipment and money, never bonuses)
  and the guard matches the text `add-wilderness-scout-class.sql` creates, so
  a rebuild reaches the same state in either order. The smoke case landed as
  a `Wilderness Scout bonuses (p.99)` section: it pins the whole corrected
  block in the book's numbers through the real parser, proves the original
  `sdc:` shape still draws the ignored-group warning, and ties the fix
  script's lines and guard to the add script. `class-check --remote` reads
  ready with zero warnings on the fixed markdown; readbacks
  `fixed 1, old_left 0, cr_free 1`, idempotent on re-run.

### F4 — high — the Crazy heals like a Vagabond: 1D6 Hit Points where the book gives 5D6, and the +1D6 P.E. is gone

- **Class**: `crazy` (RUE p.53-57)
- **Book says** (p.55, "1. Super Endurance"): "Add 3D6x10 to S.D.C., add
  **5D6 to Hit Points**, and **+1D6 to P.E.** attribute."
- **Production says**: `pools: { sdc: "3d6x10", hp: "1d6" }`; attributes carry
  PS/Spd/PP but no PE. (PS 2d4 min 19, PP 1d6 min 17, Spd 4d6, init/attacks/
  roll and all five save lines verified correct.)
- **Fix sketch**: `fix-crazy-super-endurance.sql` — `hp: "1d6"` → `"5d6"`,
  add `PE: "1d6"` to `bonuses.attributes`.
- **Taken, 2026-08-25**: `fix-crazy-super-endurance.sql`, as sketched — two
  guarded single-line replaces, each `instr()`-gated on the exact production
  text (verified against a fresh `--remote` pull, which matches what
  `add-crazy-class.sql` creates). The book line re-read from the OCR cache
  (rue p058, printed 55) before writing. The name sorts after
  `add-crazy-class.sql`, the only script writing this block; the later
  crazy-touching scripts (`fix-language-picks.sql`, the `zz-` notes) edit
  language lines and occ_group, never these two. Readbacks
  `fixed 1, old_left 0, cr_free 1`, idempotent on re-run;
  `class-check --remote` on the fixed markdown reads ready with zero
  warnings. Everything else in the block left untouched per the audit.

### F5 — high — Cyber-Knight's combat block, attribute line and psionics all disagree with RUE

- **Class**: `cyber-knight` (RUE p.61-66; D1-only, no `add-` script; the
  2026-08-25 re-audit fixed skills but not these)
- **Book says**: p.63 — "+1D4 to M.A., M.E., P.S., **P.P.**, P.E., and Spd";
  "Combat Bonuses: +1 attack/action per melee, **+3 to initiative**, +3 to
  Perception Rolls, **+2 to pull punch**, and **+2 to disarm**. **+1 to save
  vs Horror Factor at levels 2, 5, 8, 12 and 15**". p.64 — Major Psychic:
  "I.S.P. Base: 6D6 **+ M.E. attribute number**, +1D6 I.S.P. per level …
  Select a total of **six** additional psychic powers … in addition to those
  three powers known to all Cyber-Knights" (Master: 6D6+10+M.E., +2D4/level,
  8 additional + one Super). p.66 — "Minimum **P.E. of 11** … What is required
  is a strong will (M.E. 11+)".
- **Production says**: `combat: { initiative: 1, attacks: 1 }` (no pull punch,
  no disarm, no perception, no HF schedule); attributes miss `PP`;
  `attribute_requirements: { ME: 11 }` only; psionics
  `isp_base: "6d6+10, +1d6 per level"` (the Master base with the Major
  per-level, and no M.E. term) with `powers_starting: 3` (the three universal
  powers, missing the Major's six additional).
- **Fix sketch**: `fix-cyber-knight-rue-bonuses.sql` — initiative 1→3, add
  `pull_punch: 2, disarm: 2, perception: 3`, add PP `1d4`, add `PE: 11`, HF
  at-level schedule, and psionics as Major (`6d6 + M.E. attribute number,
  +1d6 per level`, `powers_starting: 9` or 3+6 via schedule). The rolled-tier
  modelling half is S2 below — either is an improvement over the current mix.
- **Taken, 2026-08-26**: `fix-rue-cyber-knight-bonuses.sql` — the sketch's
  name reordered, because `fix-cyber-knight-rue-bonuses` sorts BEFORE
  `fix-cyber-knight.sql` ('-' < '.') and before `fix-pre-rue-class-audit.sql`,
  the last full-markdown writer of this class, so a clean rebuild would have
  undone it. Six guarded replaces: PE 11 joins the requirements, initiative
  1→3 with pull punch/disarm/perception, the PP die rejoins the attribute
  line, the HF at-level schedule (anchored on the corrected attribute line so
  re-runs no-op), psionics as the Major tier (`6d6 plus M.E. attribute
  number, +1d6 per level`, powers_starting 9), and the now-false
  three-powers extraction note rewritten in the same script per the
  claim-audit rule. S2's d100 tier table stays unmodelled. All guards match
  fresh `--remote` pulls; readbacks `fixed 1, old_left 0, cr_free 1`,
  idempotent; `class-check --remote` ready with zero warnings.

### F6 — high — eight mage classes' P.P.E. and six psychics' I.S.P. drop the book's attribute term

The early RUE imports (8/18-19) wrote pool bases without the "+ P.E./M.E.
attribute number" the book prints; the later PF imports all carry it
(`diabolist`, `druid`, `priest-of-light/darkness`, `psi-mystic`, `wizard`,
`summoner` — and `mind-melter`'s I.S.P.), and `dice.js` parses the phrase
explicitly ("2D4x100+200 plus P.E. attribute number" is a documented case). In
several classes the dropped term also survives in the class's own
`special_abilities` prose, so the sheet contradicts itself. ~10-20 points of
P.P.E./I.S.P. lost per character.

- **P.P.E. missing "+ P.E. attribute number"** (each cite verified):
  ley-line-walker (RUE p.116), ley-line-rifter (p.117), mystic (p.119
  "1D6x10+20 plus P.E. attribute number"), shifter (p.124), techno-wizard
  (p.128 "3D4x10, in addition to the P.E. attribute"), elemental-fusionist
  ×2 (p.101), warlock (both variants; its own prose says "in addition to the
  P.E. attribute").
- **I.S.P. missing "+ M.E. attribute number"**: burster (p.141 "3D4x10 plus
  the character's M.E."), psi-stalker & wild-psi-stalker (p.154 "M.E.
  attribute number +1D6x10"), dog-boy (p.146 "1D6x10 + M.E."), mystic (p.119
  "1D4x10+10 plus the character's M.E. … another **1D6+1** I.S.P. per each
  additional level" — the per-level term is missing too), techno-wizard
  (p.128 "4D6 plus the character's M.E. … another **1D4+1** I.S.P. per each
  additional level" — both terms missing; production is bare `"4d6"`).
  Cyber-knight is covered in F5.
- **Fix sketch**: one `fix-pool-attribute-terms.sql` appending the attribute
  term (and the two missing per-level clauses) to each `ppe_base`/`isp_base`
  string via guarded `replace()`. Regression: re-parse each and assert
  `poolFormulaBounds` moved by exactly the attribute range.
- **Taken, 2026-08-26**: `fix-rue-pool-attribute-terms.sql` (the `rue-`
  infix so it sorts after `fix-pre-rue-class-audit.sql`, which rewrites
  ley-line-walker's whole markdown). Eleven guarded replaces cover all
  twelve classes; every cite re-read from the OCR cache first, warlock's
  term taken from its own prose per the Blocked note, and its
  byte-identical base+variant strings rewritten in one `replace()` pass on
  purpose. Mystic and techno-wizard I.S.P. also gained their missing
  per-level clauses (`+1d6+1` / `+1d4+1`). The sketch's regression ran
  green: `poolFormulaBounds` re-parsed on every old/new pair with the
  attribute pinned to 13 shifted by exactly 13 min and max (cyber-knight's
  by ME-10, its old base being the Master tier's `6d6+10` — F5's fix, by
  design). Readbacks `pe_fixed 8, me_fixed 6, old_left 0, cr_free 12`,
  idempotent; all twelve re-parse ready with zero warnings.

### F7 — medium — Operator has no bonus block at all

- **Class**: `operator` (RUE p.91-92)
- **Book says** (p.92): "O.C.C. Bonuses: +1 to I.Q., +2 to P.S. and +1 to
  P.P. attributes, +2 on Perception Rolls, +2 to save vs fatigue and disease,
  and +2D6+6 [to S.D.C.]".
- **Production says**: no `bonuses` key of any kind. (Money 4d4x1000 verified
  correct — the citation trap here is that cyber-doc's money paragraph opens
  the operator's declared page window; see F17.)
- **Fix sketch**: `fix-operator-bonuses.sql` adding
  `attributes: { IQ: 1, PS: 2, PP: 1 }`, `combat: { perception: 2 }`,
  `saves: { fatigue: 2, disease: 2 }`, `pools: { sdc: "2d6+6" }`.
- **Taken, 2026-08-26**: `fix-operator-bonuses.sql`, as sketched — one
  guarded splice between `starting_money` and `skills:`. The sketch's
  `fatigue: 2` named a save key that did not exist — derive.js's map and
  sheet.js's SAVE_FIELDS are the pair that make a key real, and a bonus to
  an absent key is a number that reaches nothing — so the same PR adds
  `fatigue` to both (borrowing the P.E. row, the same way disease and
  faerie_magic joined) plus a smoke case pinning it to that row; the
  two-way save-list smoke checks hold both sides together. Readbacks
  `fixed 1, old_left 0, cr_free 1`, idempotent; `class-check --remote`
  ready with zero warnings.

### F8 — medium — dropped Perception bonuses across eleven classes (the key exists and live classes use it)

`combat.perception` is a modeled bonus key — `derive.js` folds it, and
rogue-scholar (+5) and vagabond (+4) carry it in production. These classes'
books print a Perception bonus that never made it in (all verified against the
cached page): body-fixer +2 (p.87), burster +1 (p.141), city-rat +3 (p.88),
dog-boy +5 (p.146), juicer +2 (p.79), mind-melter +3 (p.151), headhunter +2
(p.76), rogue-scientist +4 (p.96), ley-line-rifter +2 (p.117), plus
cyber-knight +3 (F5), operator +2 (F7), wilderness-scout +3 (F3). Mystic's
"+1 on Perception Rolls at levels 1, …" (p.119) is an at-level shape.
Conditional ones (elemental fusionist "in the wild", techno-wizard "involving
machines") correctly stay prose.

- **Fix sketch**: one `fix-perception-bonuses.sql` adding `perception: N` to
  each class's combat block. Note three classes' own notes claim "+N
  Perception has no bonus key" — those sentences come out in the same script
  (see S3).
- **Taken, 2026-08-26**: `fix-perception-bonuses.sql`, as sketched — the
  nine flat bonuses (body-fixer's +2 with its +4 medical half left as
  conditional prose; city-rat and rogue-scientist filling their empty
  combat blocks; rifter and mystic gaining combat blocks they never had)
  plus mystic's at-level shape: base `perception: 1` and six `at_level`
  entries at 3/6/8/10/12/14, appended after the existing save schedule
  (classBonuses folds entries sharing a level, so order is cosmetic); the
  ley-line doubling stays prose. The false notes came out in the same
  script: burster's and dog-boy's "no bonus key" sentences removed,
  body-fixer's "no Perception key exists" rewritten, headhunter's and
  rifter's "applied by hand" reworded, juicer's note now points its
  still-missing disarm at F14 (only the juicer's own perception lands
  here — the sub-classes are F14's), and city-rat's note keeps its Spd
  die-add as prose flagged as a decision to revisit, not a schema limit.
  Dog-boy's combat guard expects the disarm `fix-disease-saves.sql` (F9,
  sorts earlier) adds — one note rewrite from original to final text
  rather than two chained half-rewrites. Readbacks
  `fixed 10, sched_ok 1, notes_left 0, cr_free 10`, idempotent; all ten
  re-parse ready with zero warnings.

### F9 — medium — disease saves dropped or misattributed in six classes

The books routinely print "save vs poison **and disease**" as separate
figures; `disease` is a valid save key (rogue-scientist and warrior-monk carry
it). Verified misses:

- **body-fixer** (p.87): book "+2 vs poison and drugs, **+3 vs disease** and
  insanity, +2 HF" → production `toxins_poisons: 3, harmful_drugs: 3,
  insanity: 3, horror_factor: 2` — poison and drugs are one point high and
  disease is missing entirely.
- **cyber-doc** (p.90): "+1 to save vs poison, drugs and disease" → absent.
- **druid** (PF p.75): "+4 HF, **+2 to save vs disease**" → disease absent.
- **psi-healer** (PF p.158): "+4 to save vs **poisons and disease**" →
  `toxins_poisons: 4` only.
- **dog-boy** (p.146): "+2 to save vs disease" (physical-bonus paragraph) →
  absent. Same paragraph's "+2 to disarm" also absent.
- **elemental-fusionist ×2** (p.101): "+2 to save vs **disease** and poison"
  → `toxins_poisons: 2` only.
- **Fix sketch**: one `fix-disease-saves.sql`; body-fixer's block rewritten to
  `{ toxins_poisons: 2, harmful_drugs: 2, disease: 3, insanity: 3,
  horror_factor: 2 }`.
- **Taken, 2026-08-26**: `fix-disease-saves.sql`, as sketched — body-fixer's
  block rewritten to the book's numbers, cyber-doc's whole absent "+1 vs
  poison, drugs and disease" line added, druid/psi-healer/elemental ×2
  disease joins, and dog-boy gets both halves of its physical-bonus
  paragraph: `disease: 2` and the `disarm: 2` the finding records. Every
  cite re-read from the OCR cache (druid's line prints at printed 75, two
  pages into its entry — the class opens at 73 per F18; an earlier version
  of this note called 75 the opening page, corrected when F18's sweep
  established the pf cache's printed+2 offset). The dog-boy note
  rewrites live in `fix-perception-bonuses.sql` (F8), which sorts after
  this file and covers all three claims in one replace. One readback
  lesson: the original `disarm_ok` pattern ended at the closing brace and
  broke the moment F8 appended `perception: 5` to the same line — guard
  readbacks on prefixes that survive later scripts. Readbacks
  `fixed 7, disarm_ok 1, old_left 0, cr_free 7`, idempotent in either
  order around F8; all seven re-parse ready.

### F10 — medium — three fail-open skill restrictions offer skills the book forbids

An `except` naming a skill the catalog files in another category excludes
nothing, and each of these classes also grants that other category bare:

- **mystic** and **shifter** (RUE p.119 / p.122): "Communications: Any (+5%),
  except Laser Communications, Optic Systems, **Sensory Equipment**,
  Surveillance, T.V./Video". The catalog files Sensory Equipment under Pilot
  Related — which both classes grant as "any". The skill the book excludes is
  offered.
- **long-bowman** (PF): "Rogue: any except Locate Secret Compartments and
  **Ventriloquism**" — the catalog files Ventriloquism under Technical, which
  the class grants bare.
- **Fix sketch**: move each name onto the category the catalog actually files
  it under (`Pilot Related except: ["Sensory Equipment"]`, Technical
  `except: ["Ventriloquism"]`). Same family as
  `fix-dead-skill-restrictions.sql`; the sweep that found these (parse every
  class against `SELECT name, category FROM skills`) is cheap to re-run after
  any rename.
- **Taken, 2026-08-26**: `fix-misfiled-excepts.sql`, as sketched — Sensory
  Equipment moves from mystic's and shifter's Communications excepts onto
  their bare `- "Pilot Related"` grants (now entries with the except), and
  Ventriloquism from long-bowman's Rogue except onto its bare Technical
  grant. Book lines and catalog categories both re-verified. One readback
  lesson: shifter legitimately grants its own bare `- "Technical"`, so the
  old-text sweep had to be scoped per class or it read a working grant as
  leftover damage. Readbacks `fixed 3, old_left 0, cr_free 3`, idempotent;
  all three re-parse ready against the remote catalog.

### F11 — medium — four choice options resolve to no catalog row, so the pick fails

Pick resolution is case-insensitive but otherwise exact (no redirects), and a
name with no row errors with `No skill called "X" in the catalog`:

- **body-fixer**: `from: ["Athletics (General)", "Body Building"]` — the
  catalog rows are "Athletics (general)" (case-only; works at runtime, but
  D1's case-sensitive Confirm will create a duplicate stub on any re-import)
  and "**Body Building & Weight Lifting**" (real miss — the pick fails).
- **vagabond**: `from: ["General Repair", …]` → catalog "General Repair &
  Maintenance". Also this choice's note carries "+10% / +5%" that the entry
  itself doesn't apply.
- **rogue-scholar**: `from: ["Automobile", "Pilot: Hover Vehicle"]` → catalog
  "Hover Craft (ground)" (a redirect exists from "Pilot: Hovercraft" but picks
  don't consult redirects). Same class: the related-skill category is written
  as `{ name: "Horsemanship: General", only: ["Horsemanship: General"] }` —
  "Horsemanship: General" is a skill, not a category, so the entry matches
  nothing and the class offers no horsemanship at all; it should be
  `{ name: "Horsemanship", only: ["Horsemanship: General"] }`.
- **Fix sketch**: `fix-broken-pick-options.sql` renaming the three options to
  their catalog spellings (case fix included) and rewriting rogue-scholar's
  category entry.
- **Taken, 2026-08-26**: `fix-broken-pick-options.sql`, as sketched — the
  three renames plus the case fix, and rogue-scholar's category entry now
  names the category. All four catalog spellings confirmed over `--remote`
  first ("Automobile" is a real row and stays). Vagabond's "+10% / +5%"
  note is left standing: it quotes the book accurately and says the entry
  does not apply the split bonuses, which remains true. Readbacks
  `fixed 3, old_left 0, cr_free 3`, idempotent; all three re-parse ready
  against the remote catalog.

### F12 — medium — Valkyrie's racial S.D.C. is an `sdc_base`, so an occupation's S.D.C. is silently lost

- **Class**: `valkyrie` (Pantheons of the Megaverse p.167)
- **Book says**: "S.D.C./Hit Points (for non-M.D.C. worlds): 100 S.D.C.
  **plus that gained from physical skills**."
- **Production says**: `sdc_base: 100`. Per the documented `combineClasses`
  precedence (the Troll Knight case), a Valkyrie + O.C.C. character carries
  exactly 100 instead of 100 + the O.C.C.'s roll, and nothing looks unusual.
  (Asgardian Dwarf, imported the same day, has the same book phrasing and the
  correct `pools: { sdc: 60 }` — the convention was known.)
- **Fix sketch**: `fix-valkyrie-sdc-pool.sql` — delete `sdc_base`, add
  `bonuses: { pools: { sdc: 100 } }`.
- **Taken, 2026-08-26**: `fix-valkyrie-sdc-pool.sql`, as sketched. The
  Pantheons PDF was not in the OCR cache when this shipped, so the book
  line stood on this audit's verified quote — **re-verified later the same
  day** when the PDF returned and was re-cached (`potm`, reader page =
  printed+1): printed 167 reads "100 S.D.C. plus that gained from physical
  skills" verbatim, and the High Elf's contrasting "plus those gained by
  O.C.C.'s and physical skills" wording sits on the same cache page,
  exactly as the rewritten note describes. The class's own extraction
  note argued `sdc_base` deliberately (self-contained wording, no O.C.C.
  mention) — overturned by the settled pool rule and rewritten in the same
  script to record why (the claim-audit rule). No `CORE_SDC_BY_CLASS`
  entry needed: the class keeps its `mdc_base`. Readbacks
  `fixed 1, old_left 0, cr_free 1`, idempotent; re-parses ready.

### F13 — medium — the Dragon Hatchling parent is missing its power schedule and its combat framework

- **Class**: `dragon-hatchling` (original Rifts core p.98-101; D1-only, no
  `add-` script — the one true screenshot-era survivor)
- **Book says** (p.100): "player can select a total of eight psychic powers
  from any of the psychic categories except super. **Select an additional four
  at fifth level and another four at tenth level.**" And: "Combat abilities:
  **Equal to hand to hand: basic**, +1 melee attack."
- **Production says**: `powers_starting: 8` with no `powers_schedule`; no
  `Hand to Hand: Basic` anywhere in `occ_skills` (the RUE hatchling variants
  model both — their `powers_schedule` is the shape to copy).
- **Fix sketch**: `fix-dragon-hatchling-core.sql` — add
  `powers_schedule: [{level:5, count:4}, {level:10, count:4}]` and a
  `Hand to Hand: Basic` occ_skill. Everything else in the class (attribute
  dice, M.D.C. 1D4x100+50, P.P.E. 2D6x10, I.S.P. 3D4x10, natural abilities,
  the 6-skill/98% literacy program, +4 skills at 4 and 8) verified correct
  against the core book.
- **Taken, 2026-08-26**: `fix-rifts-core-dragon-hatchling.sql` — the
  sketch's name reordered twice over: `fix-dragon-hatchling-core` sorts
  BEFORE `fix-pre-rue-class-audit.sql`, the last full-markdown writer of
  this class, and collides with the existing `fix-dragon-hatchling.sql`
  prefix. The core-book PDF is not in the OCR cache on this machine today,
  so the lines stand on this audit's verified quotes. `powers_schedule`
  in the RUE variants' shape with the core counts (4 at 5 and 10;
  `categories_allowed` already carries the no-Super constraint), and
  `Hand to Hand: Basic` joins occ_skills — one correction to this
  finding's own text: the RUE variants model the SCHEDULE, but none
  carries a Hand to Hand skill (their books print enumerated combat
  bonuses instead), so the occ_skill shape here is the ordinary one other
  classes use, not copied from a variant. Readbacks
  `fixed 1, old_left 0, cr_free 1`, idempotent; re-parses ready against
  the remote catalog. **Decision (Nate, 2026-08-26): the original Rifts
  core defaults to the RUE version** — when hatchling material needs book
  verification and the core PDF is not at hand, RUE (cached) is the
  authority to check against rather than chasing the original printing.

### F14 — medium — Juicer's "+2 to disarm" is missing, and three Juicer Uprising sub-classes copied the gap

- **Book says** (RUE p.79): "+2 attacks, +4 on initiative, +2 on Perception
  Rolls, **+2 to disarm**, +2 to pull punch, +3 to roll with impact".
- **Production says**: `juicer` has initiative/attacks/roll/pull but no
  disarm (and no perception — F8). `juicer-gladiator`, `juicer-assassin` and
  `juicer-scout` deliberately carry "the standard Juicer's numbers" (their
  notes say so), so all three inherit the miss.
- **Fix sketch**: one script adding `disarm: 2` (and `perception: 2`) to all
  four. The juicer's own note claiming "+2 Perception, +2 disarm … have no
  bonus key" is false (S3) and comes out in the same change.
- **Taken, 2026-08-26**: `fix-rue-juicer-disarm.sql` (the `rue-` infix so
  it sorts after `fix-perception-bonuses.sql`, whose juicer output it
  guards on, and after `fix-juicer-rue-edition.sql`, the block's earlier
  writer). The juicer gains its disarm beside the perception F8 added; the
  three sub-classes gain both keys in one pass, so their "standard
  Juicer's numbers" notes stay true. The F8-era note ("+2 disarm is not
  yet applied") rewritten now that it is. Readbacks
  `fixed 4, note_ok 1, old_left 0, cr_free 4`, idempotent; all four
  re-parse ready.

### F15 — medium — Knight (PF) has no bonus block

- **Book says** (PF p.85): "3. Other O.C.C. Bonuses: +1 on initiative, +2 to
  pull punch, and +1 to save vs horror factor at levels 1, 3, 6, 8, 10
  and 12."
- **Production says**: no `bonuses` key. (Palladin, printed beside it with the
  same shape, has its full block including the HF schedule — the Knight was
  just skipped.)
- **Fix sketch**: `fix-knight-bonuses.sql` — `combat: { initiative: 1,
  pull_punch: 2 }`, `saves: { horror_factor: 1 }`, at_level HF at
  3, 6, 8, 10, 12.
- **Taken, 2026-08-26**: `fix-knight-bonuses.sql`, as sketched — one
  guarded splice between `starting_money` and `skills:`, the book line
  re-read from the PF cache (p087): the level-1 horror factor point in the
  base saves, the rest on the at_level schedule, palladin's shape.
  Readbacks `fixed 1, old_left 0, cr_free 1`, idempotent; re-parses
  ready.

### F16 — low — five classes are missing printed money, all verified against the page

- **city-rat** (RUE p.89): "Starts with 6D6x100 credits and a Black Market
  item of some [value]" → no `starting_money`.
- **vagabond** (RUE p.98): "Money: 2D6x100 in credits and 2D6x100 in Black
  Market saleable [goods]" → none.
- **coalition-grunt** (RUE p.233): "Monthly salary is 1700 credits. Starts off
  with one month's [pay]" → none (samas-pilot models the same shape as
  `"2000 credits monthly salary"`).
- **coalition-technical-officer** (RUE p.236): "A monthly salary of 2200
  credits. Starts off with one month's" → none.
- combat-cyborg's is part of F1.
- **Fix sketch**: one `fix-missing-starting-money.sql`; black-market halves
  stay prose per the coin-only rule.
- **Taken, 2026-08-26**: `fix-missing-starting-money.sql`, as sketched, with
  F20 riding it per its own sketch. All four money lines re-read from the
  cache; the salary pair uses samas-pilot's "N credits monthly salary"
  convention. Each class gained an extraction-note bullet naming its page
  and the prose half (black-market items, one-month's-pay), and city-rat's
  "no starting money appears on this page" claim was trimmed to stay true.
  Readbacks `money_ok 4, psi_ok 1, old_left 0, cr_free 4`, idempotent; all
  four re-parse ready.

### F17 — low — missing attribute requirements in seven classes, and three page ranges end a page early

Attribute requirements verified against the printed line and absent in
production:

- **coalition-samas-pilot** (p.235): I.Q. 12, M.E. 12, P.E. 10 (also "Racial
  Restrictions: Human" — worth confirming the race restriction row covers it).
- **cyber-doc** (p.90): I.Q. 11, P.P. 12.
- **glitter-boy** (p.70): P.P. 10.
- **rogue-scholar** (p.94): I.Q. 10, M.A. 10.
- **rogue-scientist** (p.96): I.Q. 12.
- **elemental-fusionist ×2** (p.104): M.E. 12, P.E. 12.
- **long-bowman** (PF p.84): P.S. 10, P.P. 12.
- (cyber-knight's P.E. 11 is in F5; mega-juicer's and delphi-juicer's
  psionics prerequisites are deliberately restrictions, documented in their
  notes — not flagged.)

Page ranges that stop before the class's own stat block, which starves
`--field-sources` (each verified by finding the Money/Cybernetics paragraph on
the next printed page): **cyber-knight** p.61-66 → 61-67, **operator**
p.91-92 → 91-93, **coalition-grunt** p.231-232 → 231-233, **combat-cyborg**
p.45-47 → 45-48 (F1).

- **Fix sketch**: `fix-attr-reqs-and-ranges.sql` — one guarded replace per
  class.
- **Taken, 2026-08-26**: `fix-rue-attr-reqs-and-ranges.sql` — smaller than
  the finding, because **five of the seven absence claims were false**:
  cyber-doc, glitter-boy, rogue-scholar, rogue-scientist and long-bowman
  all carry their printed requirements in multi-line blocks their add
  scripts have held since before this audit was written (git shows the
  files untouched since 8-21; F5 read cyber-knight's block fine, so the
  shape parses — the audit likely grepped the inline `{ }` form). What was
  real: samas-pilot carried WRONG values (IQ 10/PP 10 where printed 235
  says IQ 12, ME 12, PE 10 — corrected), and the elemental fusionists were
  truly absent (their note read the whole printed line as a
  recommendation; the trailing clause covers only the I.Q./P.S. 10, the
  cyber-doc pattern — note rewritten). Ranges: the three listed plus TWO
  the list missed, caught because F16's money cites sit on the missing
  pages — city-rat 88-88→88-89 and vagabond 97-97→97-98. The sketch's
  name sorted before `fix-pre-rue-class-audit.sql`, cyber-knight's last
  full writer — hence the `rue-` prefix. Readbacks
  `reqs_ok 3, ranges_ok 5, old_left 0, cr_free 8`, idempotent; all eight
  re-parse ready.

### F18 — low — 39 classes have no page range in `source_book` at all, so the page-break defence cannot run on them

The 24 `palladium-fantasy-core` classes, the 14 `pantheons-of-the-megaverse`
classes and `chiang-ku-dragon` (`dragons-and-gods`) carry a bare slug;
`dragon-hatchling` says "Rifts RPG (original core book)" with no pages.
`class-check --field-sources` refuses all of them ("names no pages"), which is
exactly the check that catches the page-break family. This audit located every
one of them by hand; the pages are known:

- PF core (printed): priest-of-light 63-67, priest-of-darkness 70-71,
  warrior-monk 71-73, druid 73-78, mercenary-fighter 78-80, soldier 81-83,
  long-bowman 83-85, knight 85-87, palladin 88-90, ranger 90-91, thief 91-94,
  assassin 94-96, merchant 96, noble 96-97, scholar 97, squire 98,
  wizard 104-107, witch 112-116, diabolist 117-120, summoner 135-137,
  psychic-sensitive 156-157, psi-healer 158-159, mind-mage 161-163,
  psi-mystic 160 — worth re-confirming each start/end when writing the script.
- Pantheons (printed): rifts-priest 12-16, godling 16-17, demigod 17-19,
  scorpion-person 57-59, greater-cyclops 92-94, naga 141-142, daitya 142-143,
  dakini 143-144, norse-giant 163-166, asgardian-dwarf 166-167,
  asgardian-high-elf 167, valkyrie 167-168, berserker 168-170,
  warrior-of-valhalla 170-171.
- chiang-ku-dragon: Dragons & Gods p.23-24. dragon-hatchling: Rifts RPG
  p.98-101.
- **Fix sketch**: one script appending ` p.N-M` to each `source_book`. Cheap,
  and it arms `--field-sources` for every future audit.
- **Taken, 2026-08-26**: `fix-source-book-pages.sql` — all forty stamped
  (24 PF + 14 Pantheons + chiang-ku-dragon + dragon-hatchling's pageless
  title), N-N form for single-page entries, guards including the trailing
  newline so a stamped line never re-matches. The re-confirmation this
  entry asked for ran for all 24 PF start pages — each class name appears
  on its start page — and established that **the pf cache runs at
  printed+2**, not the offset-zero first assumed (knight's p.85 line at
  cache p087, druid's p.75 line at p077, psi-healer's p.158 at p160 all
  agree). The Pantheons and Dragons & Gods PDFs were not in the OCR cache
  when this shipped, so those 16 ranges stood on this audit's hand-located
  numbers — **the Pantheons PDF returned later the same day** and was
  re-cached (`potm`, text layer, reader page = printed+1 per
  read-columns.py's own note that the printed-to-pymupdf offset is zero):
  all 14 start pages confirmed by heading sweep (the High Elf's heading is
  the plural "Asgardian High Elves"), plus the valkyrie money at printed
  168 and the berserker's "Money: None to start." at printed 170. **The
  Dragons & Gods PDF returned the same evening** and was cached as `dag`
  (240 pages, text layer, reader page = printed+1): the Chiang-Ku's
  verified figures — hatchling P.P.E. "2D4x10+20", adult "2D4x100+200 plus
  P.E. attribute number" — and the Basilisk's "2D4x10+40" trap line all
  read verbatim, but on printed 22-23, ONE PAGE LOWER than the audit's
  hand-located p.23-24 (folio-confirmed: 22 carries the heading and stat
  block, 23 the Rifts stats, 24 opens the Cockatrice). The stamp is
  corrected by `fix-stamp-chiang-ku-range.sql`, which sorts after this
  finding's script — and NOT named `fix-source-book-pages-chiang-ku`,
  because '-' sorts before '.' and that name would run before the file it
  corrects. Proven armed: `--field-sources` on the stamped knight resolves
  the pf cache, and on the corrected chiang-ku resolves `dag` (offset +1
  from 204 folios) and maps p.22-23 to exactly its pages. Readbacks
  `pf_ok 24, pom_ok 14, rest_ok 2, bare_left 0, cr_free 40`, idempotent;
  spot-checked classes re-parse ready.

### F19 — low — Ley Line Walker and Rifter drop their attribute-of-choice bonus

- **Book says**: walker (p.116) "+1D4 on any one Mental attribute (I.Q., M.E.
  or M.A.)"; rifter (p.117) "+2 on any one Physical attribute (P.S., P.P.,
  P.E., P.B. or Spd.)".
- **Production says**: neither has any attribute bonus; both notes say
  "chosen or applied by hand". That was true when written; a
  `special_abilities` choice group now grants `bonuses` (ABILITY_GRANTS —
  the Godling's eleven powers are the precedent), so a three-option /
  five-option choose-1 models it exactly.
- **Fix sketch**: `fix-walker-rifter-attribute-choice.sql` adding the choice
  groups and trimming the by-hand sentences. Their Spell Strength schedules
  genuinely stay prose (no key — see the still-true list).
- **Taken, 2026-08-26**: `fix-walker-rifter-attribute-choice.sql` — the
  RIFTER half only, because a fresh `--remote` pull shows the walker
  already carries its three-fragment choose-1 group with a correct note
  (this finding's "neither has any attribute bonus" was half-stale by
  execution time). The rifter gains five `special_abilities` fragments
  (+2 each to P.S./P.P./P.E./P.B./Spd) behind a choose-1 group — the
  walker's own shape — and its two notes claiming the choice inexpressible
  or by-hand are rewritten. Spell Strength stays prose as stated.
  Readbacks `fixed 1, walker_ok 1, old_left 0, cr_free 2`, idempotent;
  re-parses ready.

### F20 — low — Vagabond's "+1 save vs possession **and psionic attacks**" lost the psionics half

RUE p.97 prints both; production has `possession: 1` only. One-line fix,
could ride F16's script.

- **Taken, 2026-08-26**: rode `fix-missing-starting-money.sql` (F16) as
  sketched — `psionics: 1` beside the possession point, and the extraction
  note that called the half ambiguous now says it is filed. See F16's
  Taken note for the readbacks.

---

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

Everything else was verifiable — every other source book is on this machine.

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
- **S2 — Cyber-Knight: "The 80% chance of having psionics at all is a
  per-character roll the class schema cannot state."** False —
  `psionics_allowed` rolled tiers exist (`rollsForPsionics`, wizard briefing,
  smoke-pinned). Its second note, "psionics gates by category rather than by
  name", is also false — `powers_from` exists (burster). Migration: model the
  d100 tiers and the named nine-power list; pairs with F5.
- **S3 — "no bonus key" notes falsified by `perception`/`disarm`:** burster
  ("+1 Perception has no bonus key and sits in restrictions"), juicer ("+2
  Perception, +2 disarm … have no bonus key"), ley-line-walker ("neither
  spell strength nor perception is a [key]" — half false),
  ley-line-rifter/headhunter ("applied by hand"). Fixed by F8/F14 plus note
  rewrites.
- **S4 — Godling: the extraction note says the category bonuses "(Domestic
  +10%, Medical +10%, Technical +10%, Wilderness +5%) have nowhere to go in
  the format and are not applied", and that Horsemanship is "offered as a
  category without the bonus".** Both false in the same file: the data above
  the note carries `bonus: 10/10/10/5` **and** `Horsemanship bonus: 15`. Pure
  note rot — rewrite only, no data change.
- **S5 — Walker/Rifter attribute-of-choice "by hand"** — expressible via
  ability choice groups; taken as F19.
- **S6 — Witch: the Gift of Power's four-from-eleven "would need bonuses the
  shape cannot express together."** Partially false — an ability may now
  carry `bonuses` + `psionics` + `magic` together (ABILITY_GRANTS), which
  covers most of the eleven; flight and the impervious set stay prose. The
  Gift of Magic's spell allotment stays blocked (variants still cannot carry
  `magic` — verified). Modeling the eleven is a real project; user's call.
- **S7 — Dog Boy: breed bonuses "are player options that no schema field
  holds."** `variants` override `bonuses` now — twenty breeds as variants is
  expressible, if bulky. User's call.
- **S8 — Goblin: the Cobbler sub-race "the app cannot express one yet."**
  Half false — a variant carries its `ppe_base` (3D4x10+1D6/level) and save
  bonuses; its faerie-magic spell grants still don't fit (no `magic` on
  variants).
- **S9 — Delphi Juicer / Mind Mage: per-category starting-power splits
  ("3 Physical + 1 Super", "three from each of four").** `powers_schedule`
  entries carry `categories` (mystic's level-4/8 Super picks) — whether a
  level-1 schedule entry fires at creation needs a check before calling this
  expressible; flagged for a look rather than asserted.

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
