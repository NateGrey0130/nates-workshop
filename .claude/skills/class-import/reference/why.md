# Why each class-import rule exists

`SKILL.md` states the rules. This file holds the incident behind each one, for
when a rule looks wrong and you are about to break it. Nothing here is a rule
that `SKILL.md` does not also state. Read an undated claim as true on the day it
was written.

## Sessions and the README

- **Fresh session every 2–4 PRs.** The 2026-08-25 efficiency audit measured the
  same PR-shaped import costing 2–7× more late in a marathon session than early,
  purely from re-carried context.
- **Never read the README end to end.** The same audit measured it read ~460
  times across the book sessions, 37 of them in full, and every full read
  re-carries for the rest of the session. `readme-section.mjs` bounds a section
  by the next heading **of any depth**, the rule a 544-line section-eating edit
  taught.

## class-check

- **`--field-sources` and the continuation block.** Both shipped
  `starting_money` errors were paragraphs that continued past a page break the
  reading stopped at (PR #280). The flag resolves the book, window and page
  offset from `source_book` and the cache (`--book` / `--offset` override).
- **`--remote`, and why local is dangerous in the BEHIND direction.** Local D1
  accumulates extra rows (a false duplicate report, harmless), and it has also
  been **52 skills short**: 293 against production's 345 on 2026-08-30. A
  missing row makes `class-check` print stub SQL, `--emit-script` writes the
  stub into `add-<id>-class.sql`, and the stub sorts before the file that
  creates the row properly, so on a clean rebuild the stub wins.
  `rebuild-local.mjs` does not help: it builds a separate sqlite file, not the
  wrangler `--local` D1 that `class-check` and the app read. `--remote` is slow
  enough to time out a two-minute call on four classes.
- **The restriction floor.** The Priest of Light names `W.P. Siege` and
  `W.P. Large Axes` ahead of those rows existing, and says so; the exclusions
  activate when the rows arrive. The floor was three until `W.P. Lance` was
  imported. Re-measured `--remote` on 2026-09-08: exactly two, out of 1,499
  restriction names across 225 live classes.
- **Unmatched is usually a bug.** A sweep of every `only`/`except` on
  2026-08-25 found nine unmatched names: two were the Priest of Light's, and
  **seven were dead exclusions**. Six classes named `Robots and Power Armor`
  after the catalog renamed it `Robots & Power Armor`, each silently offering the
  one Pilot skill its book forbids. `regression.mjs` now runs the sweep and pins
  the floor by NAME, against the scratch D1, never `--remote`. The Robot Pilot
  cites the same old string in a GRANT and is fine, because grants follow
  redirects.

## Names and conventions

- **The Pilot category is mixed.** 51 rows `--remote` on 2026-09-08: 29 with a
  `Military:`, `Boat:`, `Space:` or `Robot Combat Elite:` prefix, 22 bare. This
  skill once said *"Pilot skills store without a prefix"*, which was true on
  2026-08-19 (PR #133) and was inverted two days later by PR #180 (`Jet Fighters`
  → `Military: Jet Fighters`), leaving that sentence as the last copy of a dead
  convention. It produced a dead `except` on its first use (`BOOK-INGEST-AUDIT`
  F35). `Jet Fighters` still redirects to `Military: Jet Fighters`.

## Data script safety

- **Pure ASCII in comments too.** Wrangler on Windows has turned a commented
  non-ASCII character into mojibake in production. The smoke test checks the
  whole file (`every data script is pure ASCII`) and the values
  (`no .sql has non-ASCII in executable SQL`) separately; both failures reached
  production (#93, #101).
- **Racial S.D.C. as a pool bonus.** Written as `sdc_base`, `combineClasses`
  gives the race's pool precedence over the occupation's, so a Troll Knight
  carried 40 instead of 40 + 3D6 and nothing on the sheet looked unusual.
  Palladium Fantasy printed 18: *"All S.D.C. points/bonuses are cumulative."*
- **`men_of_arms` in the class.** Until 2026-09-25 the grouping was the map
  `CORE_SDC_BY_CLASS` in `js/compose.js`, and every import appended to it. The
  map is gone; its entries live in the classes.
- **Sort order.** `fix-long-bowman-armor.sql` sorted before
  `fix-long-bowman.sql` (`-` 0x2D, `.` 0x2E) and was overwritten on every
  rebuild. Only `repo-vs-live.mjs` caught it, because production had them in the
  order they were run by hand. The armor file has since been folded away. `zz-`
  was adopted to mean "sorts after everything" and the tier has since escalated
  to `zzzzz-`, so a new `zz-` sorts before three dozen files.
- **One class per `add-` file.** Four classes in one file left all four
  unaccounted for in the smoke test's file-to-id map.
- **Catalog ids.** Measured 2026-09-05, a database rebuilt from the repo matched
  production on **0 of 1025 gear ids**. `WHERE id = 283` was `Fire: Fire Gout`
  in production and `Earth: Track` in the rebuild.

## Modelling

- **`KNOWN_KEYS` false alarms.** It is hand-kept on purpose, because the
  question is whether anything downstream acts on a key, not whether the parser
  touches it.

  | key | reported as unmodelled | actually |
  |---|---|---|
  | `psionics_allowed` | by the first six races to use it | modelled all along: `rollsForPsionics()`, the wizard's Race briefing, a smoke check |
  | `xp_table` | by anything that ever uses it | supported since `leveling.js` was written, read by six call sites |

  A false alarm is worse than a miss here, because the instruction attached to
  the report is *delete the key or change the app*, and both break a working field.
- **`combat` and `saves` closed at the sheet.** This skill once said a new key
  there "costs nothing". `validateBonuses` checks group names, not the keys
  inside, and `addBonus` adds any finite number under any key, so an invented
  key is stored and invisible. `derive.js` and `SAVE_FIELDS`/`COMBAT_FIELDS` have
  drifted once already.
- **Things that started as a needed app change:** the Godling's Magic Powers
  demanding an occupation, staged R.C.C.s needing `variants`, variable P.P.E.
  costs, and skills granting attribute bonuses.
