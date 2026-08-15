# PR 10 — Server-side rule enforcement

> **Delivered** in [#26](https://github.com/NateGrey0130/nates-workshop/pull/26). This file is the record of why, not a to-do.
> Narrowed: choice groups warn rather than block. See the plans index.

## Problem

Skill counts, category restrictions, and attribute minimums are enforced in the
wizard. The server validates shape, ownership, and campaign existence only. It is
fine for a friends-only app behind Access, but it is not a boundary — a client
bug silently writes an illegal character, and nothing catches it.

Depends on PR 9: pending and claimed skill picks change what "legal" means, and
enforcement written before that would reject legitimately levelled characters.

## Decisions

**Enforce exactly the rules the wizard already enforces** — skill counts,
category restrictions, attribute minimums — re-checked server-side against the
class definition. Rejected: also recomputing derived values, which fights the
deliberate design where the sheet's combat, saves, and pool fields are
hand-editable and stored values win over the tables. Also rejected: adding level
and XP integrity checks, which is a reasonable later PR but a different concern.

**Validate new writes only; report existing violations separately.** Characters
already saved keep loading and saving. A one-off admin report lists which
characters break which rule, so you decide case by case. Rejected: strict
rejection from day one, which could block a character mid-session; and
warn-only, which is not a boundary at all.

## Work

**A shared validator.** New
`functions/api/character-creator/_lib/validate-character.js`, taking a character
and its resolved class definition and returning a list of violations rather than
throwing. Both the write path and the report use it, so they cannot disagree.

Rules to implement:

- **Skill counts** — the number of chosen O.C.C. related and secondary skills is
  within what the class grants at the character's level, including grants claimed
  through PR 9's pending picks.
- **Category restrictions** — chosen skills fall within the categories the class
  permits, honouring the override flag PR 9 introduces. An explicitly flagged
  override is legal; an unflagged out-of-category skill is not.
- **Attribute minimums** — the class's `attribute_requirements` are met. Watch
  the historical bug here: the importer once encoded "none" as a literal
  requirement. A requirement of `none`, `null`, or empty means no requirement.
- **Choice groups** — `isChoiceGroup` entries in the class definition are
  satisfied: the right number chosen, from the right pool.

Reuse the parser's own understanding of the class format. `js/parser.js` is
already shared between browser and Workers runtime, so the server can read the
same structures the wizard does — do not re-implement the format.

**Write path.** Character create and update run the validator. Violations return
a 422 with a structured list the UI can display against the offending fields, not
a flat message. Ownership and campaign checks stay where they are, and run first
— a 403 should not be reachable by way of a validation error.

**Grandfather report.** An admin-only route that runs the validator across every
character and returns the violations found, grouped by character. Read-only. It
never modifies anything, so running it is always safe.

**Client alignment.** The wizard shows server violations rather than only its
own. Where the two disagree, the server is right; the wizard's checks become a
convenience that avoids a round trip, not the source of truth.

## Acceptance

- Creating a character with more skills than the class grants returns 422 with
  the specific violation.
- Creating a character with a skill outside the permitted categories, without an
  override flag, returns 422.
- A character legitimately levelled through PR 9's picker saves cleanly,
  including skills picked with an override flag.
- A class with `attribute_requirements` of "none" imposes no minimum.
- An existing character that violates a rule still loads and still saves.
- The admin report lists that character and names the rule broken.
- The report modifies nothing — row count and contents unchanged after running.
- A non-admin cannot reach the report.
- `node apps/character-creator/test/smoke.mjs` passes, extended to cover the
  validator directly.

## Out of scope

Derived-value recomputation, XP and level integrity checks, rate limiting, and
any automatic repair of existing violations. The report tells you; you decide.
