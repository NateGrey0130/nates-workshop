# The negatives — claims that look stale and are true

Every claim in this file **passed**. Nothing here needs fixing, and each one has
already survived at least one pass that was about to "correct" it into a
falsehood.

That is what makes them worth keeping. A claim sweep is easy to score on the
claims it catches and impossible to score on the ones it breaks, because a
broken true claim reads exactly like a fixed stale one. These are the control
group: **run a sweep over the classes named below, and any change proposed to
these sentences is a failure, no matter what else the sweep got right.**

Verified against **production** D1 on **2026-09-02**, read-only, through
`node scripts/q.mjs --remote --batch <file>`. The re-verification queries are at
the bottom; the whole file is three `SELECT`s and takes one wrangler start-up.

## Why these three and not others

All three are the same shape — **"the catalog has no X row"** — which
`SKILL.md` names as one of the two claims that repeat here. That shape is the
one a sweep gets wrong, because it is falsified by finding a row, and finding a
row is the easy half. Deciding **which table was meant** is the work.

## N1 — the Ranger's poison row

**The claim**, in `imported_classes` where `class_id = 'ranger'`, verbatim:

> `Card Shark and Use/Recognize Poison (+6%) only; the catalog has no poison row.`

**Still true.** `skills` matching `%poison%` returns **zero rows**.

**The trap, and it has grown teeth since `SKILL.md` recorded it.** `gear` now
holds **eight** rows matching `%poison%`:

| id | name |
|---|---|
| 10974 | Contact poison: Numbstrike |
| 10975 | Contact poison: Gut wrench |
| 10976 | Contact poison: Wart Callo |
| 10977 | Contact poison: Witchbane |
| 10978 | Basilisk's Eye (blood poison) |
| 10979 | Dragon's Breath (blood poison) |
| 10980 | Scorpion's Blood (blood poison) |
| 10838 | Negate Poison |

So the naive check — grep "poison", grep "catalog", count rows — returns eight
hits and every surface reason to call the sentence stale. It is not. The
sentence sits inside a **Rogue skill-category restriction**, and
`Use/Recognize Poison` is a skill. The word "catalog" is doing narrower work
than it looks like it is doing.

**To pass N1** a sweep has to notice that the claim's subject is fixed by its
surrounding block rather than by the word "catalog", and go to `skills`.

## N2 — Large Axes, in three classes

**The claim**, verbatim, in three separate class records:

| `class_id` | sentence |
|---|---|
| `diabolist` | `Any except Large Axes, Pole Arms and Lance; the catalog has no Large Axes row.` |
| `summoner` | `Any except Large Axes and the Lance; the catalog has no Large Axes row.` |
| `wizard` | `Any except Large Axes, Pole Arms and Lance; the catalog has no Large Axes row.` |

**Still true.** `skills` matching `%axe%` returns **exactly one row**:
`W.P. Axe`, id `258`, category `Weapon Proficiencies`. `SKILL.md`'s
parenthetical — *"the catalog has `W.P. Axe` and nothing else"* — is exact.

**`SKILL.md` names two of these three.** `wizard` carries the sentence word for
word and was not recorded. That is the ordinary way this file will go stale:
not the claim changing, but another class acquiring it.

**A fourth class is adjacent and is not a claim.** `priest-of-light` lists
`W.P. Large Axes` inside an `except:` list with **no** claim sentence attached.
It is in the `%large axe%` context sweep and must not be scored — a sweep that
reports it has found a restriction, not an assertion about the catalog.

## N3 — the compound version, in two more classes

**The claim**, verbatim, in `druid` and `priest-of-darkness`:

> `The book also excludes Siege and Large Axes, which have no catalog rows.`

**Still true on both halves.** `skills` matching `%siege%` returns **zero
rows**; the axe half is N2. `Weapon Proficiencies` holds 34 rows in total.

**This is the hardest of the three and the reason it is listed separately.** One
sentence asserts **two** absences. A sweep can check Large Axes, find `W.P. Axe`
and nothing else, conclude correctly, and still have verified half a claim. The
failure mode is not a wrong answer — it is a right answer to a smaller question,
which is indistinguishable from a right answer in any report that only records
the verdict.

**To pass N3** a sweep has to split the conjunction before querying, and say so.

## Scoring

**Six** class records carry a claim sentence: `ranger` (N1), `diabolist`,
`summoner`, `wizard` (N2), `druid`, `priest-of-darkness` (N3). A seventh,
`priest-of-light`, appears in the axe context sweep and carries no claim.

- Proposing an edit to any of the six sentences: **fail**.
- Reporting `priest-of-light` as a stale claim: **fail**.
- Confirming N3 without naming Siege separately: **fail**, even though the
  conclusion is right.
- Reporting all six unchanged, with the `skills`-vs-`gear` distinction stated
  for N1 and both conjuncts stated for N3: **pass**.

A sweep that simply declines to touch anything scores a false pass here. These
negatives measure precision only. Pair them with the confirmed-stale findings in
`SKILL.md` if what you want is a score.

## One figure that did not reproduce

`SKILL.md` says of N1: *"twelve poisons had just been imported."* A name match
on `gear` returns **eight**, and one of those (`Negate Poison`, id 10838, in a
different id range from the other seven) does not look like a poison at all.

This does **not** make the sentence wrong — the other four may be named without
the word, and the figure may have come from the import script rather than from
the table. It means the number is **not reproducible the obvious way**, and
nobody should quote it as if it were. It is a count in prose, sitting inside the
file about counts in prose, and it is here rather than fixed because guessing at
what it counted would be the same mistake one layer down.

## Re-verifying

Three statements, one invocation. Written to a file because
`wrangler d1 execute --command` truncates at the first newline and `--file`
returns a summary instead of rows — see `windows-shell`.

```sql
SELECT id, name, category FROM skills WHERE lower(name) LIKE '%poison%' ORDER BY name;
SELECT id, name, category FROM skills WHERE lower(name) LIKE '%axe%' ORDER BY name;
SELECT id, name, category FROM skills WHERE lower(name) LIKE '%siege%' ORDER BY name;
```

```bash
node scripts/q.mjs --remote --batch negatives.sql
```

Expected: `[]`, then `W.P. Axe` alone, then `[]`. **`--remote`, not `--local`** —
`--local` accumulates and would answer a question about this machine.

To re-find the claim sentences themselves, and catch a seventh class acquiring
one:

```sql
SELECT class_id FROM imported_classes WHERE instr(lower(markdown), 'large axes row') > 0 OR instr(lower(markdown), 'large axes, which have no catalog rows') > 0;
```

Expected: five rows. Add the Ranger and that is the six.
