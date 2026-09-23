// The power browser's search and filter. Pure: give it the catalog and the
// power tables (data/powers.json, data/power-tables.json) and it answers.

const norm = (s) => String(s).toLowerCase().replace(/[^a-z0-9]+/g, ' ').trim();

export function makeBrowser(catalog, powerTables) {
  const classes = powerTables.classes;
  const className = Object.fromEntries(classes.map((c) => [c.code, c.name]));
  const byCode = Object.fromEntries(catalog.powers.map((p) => [p.code, p]));
  const order = Object.fromEntries(catalog.powers.map((p, i) => [p.code, i]));

  // A query matches a code exactly ("MG10", "mg10"), or every word of it
  // appears in the name or the summary. An empty query matches everything.
  function search({ query = '', cls = '', doubleOnly = false } = {}) {
    const q = norm(query);
    const exact = byCode[String(query).trim().toUpperCase()] || catalog.powers.find(
      (p) => p.code.toLowerCase() === String(query).trim().toLowerCase());
    if (exact && (!cls || exact.class === cls)) return [exact];
    const words = q ? q.split(' ') : [];
    return catalog.powers.filter((p) => {
      if (cls && p.class !== cls) return false;
      if (doubleOnly && !p.double) return false;
      if (!words.length) return true;
      const hay = norm(`${p.name} ${p.summary}`);
      return words.every((w) => hay.includes(w));
    }).sort((a, b) => {
      // Name hits before summary-only hits, then book order.
      const an = words.length && words.every((w) => norm(a.name).includes(w)) ? 0 : 1;
      const bn = words.length && words.every((w) => norm(b.name).includes(w)) ? 0 : 1;
      return an - bn || order[a.code] - order[b.code];
    });
  }

  // Related Powers as display entries: a code resolves to its Power, a name stays a name.
  function related(p, kind) {
    return (p[kind] || []).map((x) => (typeof x === 'string'
      ? { code: x, name: byCode[x]?.name ?? x }
      : { code: null, name: x.name }));
  }

  return { classes, className, byCode, search, related };
}
