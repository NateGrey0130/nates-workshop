// One game's own I.S.P. cost for a psionic power the catalog already holds.
//
// BOOK-INGEST-AUDIT.md F102. `psionic_powers` holds one `isp` per power, which
// was true enough while every psionic in it was Rifts'. Heroes Unlimited and
// Nightbane print the same powers under the same names at their own prices:
// Hypnotic Suggestion is 6 I.S.P. in Rifts, 2 in Heroes Unlimited, and 2 or 4
// in Nightbane depending on which section a psychic learns it from. A second
// row would split the one name every game prints, so the price is a property of
// (power, system) and lives in `psionic_system_costs` (migration 076).
//
// THE SAME DESIGN AS `applySystemBases` in skill-base.js, for the same reason:
// the substitution is applied to the ROW, so a caller that reads `row.isp` and
// has never heard of this cannot read the wrong game's price. Every path that
// turns a catalog row into a character's `cost` - the wizard, the level-up
// picker, the NPC generator - reads `row.isp` and `row.isp_note` and nothing
// else.

/**
 * The per-system costs as a lookup, from the `psionic_system_costs` rows for
 * ONE system. Lowercased on the name, because every other name match in this
 * app is case-insensitive.
 */
export function psionicCostMap(rows) {
  const map = new Map();
  for (const r of rows || []) {
    const name = String(r?.power_name ?? r?.name ?? '').trim().toLowerCase();
    if (name) map.set(name, r);
  }
  return map;
}

/**
 * Psionic rows with one game's own costs substituted in.
 *
 * Per column, like the skill bases: a NULL `isp` keeps the row's price, and a
 * NULL `isp_note` keeps the row's note. Nightbane prints Death Trance at 1
 * I.S.P. as a Physical power - the catalog's own figure - and at 2 as a
 * Sensitive one, so its override states only the note.
 *
 * Returns NEW objects and never mutates the input: the wizard holds one catalog
 * for a whole session, and switching games mid-build must not leave one game's
 * price under another's.
 */
export function applyPsionicCosts(rows, overrides) {
  if (!overrides || !overrides.size) return rows || [];
  return (rows || []).map((row) => {
    const o = overrides.get(String(row?.name ?? '').trim().toLowerCase());
    if (!o) return row;
    const out = { ...row };
    if (o.isp !== null && o.isp !== undefined) out.isp = o.isp;
    if (o.isp_note !== null && o.isp_note !== undefined) out.isp_note = o.isp_note;
    // What a picker needs to explain a price that disagrees with the one a
    // player may have seen in another game's book.
    out.system_cost_source = o.source_book ?? null;
    return out;
  });
}
