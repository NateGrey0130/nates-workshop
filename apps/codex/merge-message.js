// The sentence a catalog merge ends on: what the merge repointed.
//
// The merge (functions/api/character-creator/_lib/catalog-merge.js) fills
// `repointed` in two shapes. A gear merge repoints foreign keys, so it sends one
// entry per referencing TABLE, `{ table, rows }`. Skills, spells and psionics
// are rewritten inside each character's JSON, so they send one entry per
// CHARACTER, `{ character_id, character }`. Counting entries as characters read
// a gear merge that moved 40 rows across three tables as "3 characters".
//
// Decided on the entry's shape, never the catalog's name, so a catalog that
// gains foreign-key references reads right without an edit here. No imports and
// no DOM, so the smoke suite runs this file as the page does.

// What a player calls each table that references gear(slug). A table missing
// here still reads, under its own name.
const TABLE_NOUNS = {
  character_items: ['inventory row', 'inventory rows'],
  campaign_items: ['stash row', 'stash rows'],
};

const plural = (n, [one, many]) => `${n} ${n === 1 ? one : many}`;

function listed(parts) {
  if (parts.length <= 1) return parts.join('');
  return parts.slice(0, -1).join(', ') + ' and ' + parts[parts.length - 1];
}

// '' when nothing moved; otherwise one sentence, ending in a full stop.
export function repointedText(repointed) {
  const entries = Array.isArray(repointed) ? repointed : [];
  const tables = entries.filter((e) => e && typeof e.table === 'string');
  const people = entries.length - tables.length;
  const parts = tables.map((e) =>
    plural(Number(e.rows) || 0, TABLE_NOUNS[e.table] || [`${e.table} row`, `${e.table} rows`]));
  if (people) parts.push(plural(people, ['character', 'characters']));
  return parts.length ? `${listed(parts)} repointed.` : '';
}
