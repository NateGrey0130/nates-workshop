// The Gear tab's rules: the Player's Book weapon and vehicle tables, searched
// and labelled. Pure, so the smoke suite runs it.
//
// Rank cells are printed as the book abbreviates them (Gd, Rm, ShX, Cl1000).
// rankOf() reads one back onto the app's ladder, case-insensitively, and
// answers null for anything that is not a rank - a number, "*", "Ty/Gd".

export function makeGear(equipment, ranks) {
  const byAbbr = new Map(ranks.ranks.map((r) => [r.abbr.toLowerCase(), r]));
  const rankOf = (cell) => (typeof cell === 'string' ? byAbbr.get(cell.toLowerCase()) ?? null : null);
  const tables = [
    ...equipment.weapons.map((t) => ({ ...t, group: 'weapons' })),
    ...equipment.vehicles.map((t) => ({ ...t, group: 'vehicles' })),
  ];

  // Every word typed must appear somewhere in the row: its name, notes,
  // includes, or any cell. A blank query keeps every row.
  function search({ query = '', group = '' } = {}) {
    const words = query.toLowerCase().split(/\s+/).filter(Boolean);
    return tables
      .filter((t) => !group || t.group === group)
      .map((t) => ({
        ...t,
        rows: t.rows.filter((r) => {
          const hay = Object.values(r).join(' ').toLowerCase();
          return words.every((w) => hay.includes(w));
        }),
      }))
      .filter((t) => t.rows.length);
  }

  return { tables, search, rankOf };
}
