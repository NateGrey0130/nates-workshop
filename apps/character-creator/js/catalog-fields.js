// One declarative description of every editable content catalog.
//
// Imported by both the browser and the Workers runtime, like parser.js and
// dice.js. It is the single place that knows what a catalog row looks like:
//
//   - the catalog editor builds its table and its row form from `fields`
//   - the write endpoints validate and coerce against `fields`, and build their
//     SQL from it rather than from anything a caller sent
//   - the PDF importers (PRs 5-7) build their extraction prompts and review
//     tables from the same entries
//
// Adding a column means adding it here, not in four places. Adding a whole
// catalog should mean adding an entry, not writing code.
//
// FIELD TYPES
//   text      short single-line string
//   longtext  multi-line string
//   int       integer, stored as-is
//   real      decimal number
//   select    one of `options`; `allowOther` keeps an unrecognised stored value
//             usable instead of silently rewriting it
//   systems   the skills.systems JSON array — NULL/absent means "both systems"
//   kv        a flat JSON object of arbitrary keys, e.g. gear.stats
//
// `blankAs` mirrors a NOT NULL DEFAULT in the schema. Several numeric columns
// are NOT NULL DEFAULT 0, so coercing an empty form field to NULL fails the
// insert. Where the column cannot hold NULL, say what empty means instead.

export const CATALOGS = {
  skills: {
    table: 'skills',
    label: 'Skills',
    // What a human calls the row, and what the DB enforces uniqueness on. They
    // differ for gear, which is keyed on slug.
    displayField: 'name',
    uniqueField: 'name',
    hasSource: true,
    fields: [
      { name: 'name', label: 'Name', type: 'text', required: true },
      { name: 'category', label: 'Category', type: 'text' },
      { name: 'base', label: 'Base %', type: 'int', blankAs: 0, help: '0 means non-percentile (W.P.s, hand to hand)' },
      { name: 'per_level', label: '+% / level', type: 'int', blankAs: 0 },
      { name: 'systems', label: 'Systems', type: 'systems' },
      { name: 'source_book', label: 'Source book', type: 'text' },
      { name: 'note', label: 'Note', type: 'longtext', help: 'Oddities: "40%/30% climb/rappel", "counts as two skills"' },
    ],
  },

  spells: {
    table: 'spells',
    label: 'Spells',
    displayField: 'name',
    uniqueField: 'name',
    hasSource: true,
    fields: [
      { name: 'name', label: 'Name', type: 'text', required: true },
      { name: 'level', label: 'Spell level', type: 'int', blankAs: 0 },
      { name: 'ppe', label: 'P.P.E.', type: 'int', blankAs: 0 },
      // Stat block. Text, not numbers — books write "100 feet per level of
      // experience" and "2D6 melee rounds" as often as they write a figure.
      { name: 'range', label: 'Range', type: 'text' },
      { name: 'duration', label: 'Duration', type: 'text' },
      { name: 'damage', label: 'Damage', type: 'text' },
      { name: 'saving_throw', label: 'Saving throw', type: 'text' },
      { name: 'area_of_effect', label: 'Area of effect', type: 'text' },
      { name: 'casting_time', label: 'Casting time', type: 'text' },
      { name: 'description', label: 'Description', type: 'longtext' },
      { name: 'source_book', label: 'Source book', type: 'text' },
    ],
  },

  psionics: {
    table: 'psionic_powers',
    label: 'Psionic powers',
    displayField: 'name',
    uniqueField: 'name',
    hasSource: true,
    fields: [
      { name: 'name', label: 'Name', type: 'text', required: true },
      // allowOther: a later book may add a category the core four don't cover,
      // and a stored value must never be silently rewritten to fit the list.
      { name: 'category', label: 'Category', type: 'select', allowOther: true,
        options: ['Healing', 'Physical', 'Sensitive', 'Super'] },
      { name: 'isp', label: 'I.S.P.', type: 'int', blankAs: 0 },
      { name: 'source_book', label: 'Source book', type: 'text' },
    ],
  },

  gear: {
    table: 'gear',
    label: 'Gear',
    displayField: 'name',
    // Gear is the odd one out: unique on slug, and it has no `source` column.
    uniqueField: 'slug',
    hasSource: false,
    fields: [
      { name: 'name', label: 'Name', type: 'text', required: true },
      { name: 'slug', label: 'Slug', type: 'text', required: true,
        help: 'What equipment_starting[].item_id references. Changing it breaks that link.' },
      { name: 'system', label: 'System', type: 'select', options: ['rifts', 'palladium-fantasy', 'both'] },
      { name: 'category', label: 'Category', type: 'select', allowOther: true,
        options: ['weapon', 'armor', 'vehicle', 'cybernetics', 'gear'] },
      { name: 'weight_lbs', label: 'Weight (lbs)', type: 'real' },
      { name: 'cost', label: 'Cost', type: 'int', help: 'Credits (Rifts) or gold (Palladium Fantasy)' },
      { name: 'stats', label: 'Stats', type: 'kv', help: 'damage, MDC, range, payload…' },
      { name: 'description', label: 'Description', type: 'longtext' },
      { name: 'source_book', label: 'Source book', type: 'text' },
    ],
  },
};

export const CATALOG_KEYS = Object.keys(CATALOGS);

export function getCatalog(key) {
  return Object.prototype.hasOwnProperty.call(CATALOGS, key) ? CATALOGS[key] : null;
}

// Columns this catalog is allowed to read or write. Every SQL statement builds
// its column list from here, so a caller can never name a column itself.
export function fieldNames(cat) {
  return cat.fields.map((f) => f.name);
}

// Turn whatever arrived over the wire into the value that belongs in the column,
// or return an error string. Coercion lives here so the API and any future
// caller agree on what "empty" means.
export function coerceField(field, raw) {
  const blank = raw === undefined || raw === null || raw === '';

  if (field.required && blank) return { error: `${field.label} is required` };

  switch (field.type) {
    case 'int':
    case 'real': {
      if (blank) return { value: field.blankAs ?? null };
      const n = field.type === 'int' ? parseInt(raw, 10) : parseFloat(raw);
      if (!Number.isFinite(n)) return { error: `${field.label} must be a number` };
      return { value: n };
    }
    case 'systems': {
      // NULL means "applies to both systems" — an empty array would mean
      // "applies to neither", which is never what anyone intends.
      if (!Array.isArray(raw) || raw.length === 0) return { value: null };
      const allowed = ['rifts', 'palladium-fantasy'];
      const picked = raw.filter((s) => allowed.includes(s));
      if (picked.length === 0 || picked.length === allowed.length) return { value: null };
      return { value: JSON.stringify(picked) };
    }
    case 'kv': {
      if (blank) return { value: '{}' };
      let obj = raw;
      if (typeof raw === 'string') {
        try { obj = JSON.parse(raw); } catch { return { error: `${field.label} is not valid JSON` }; }
      }
      if (typeof obj !== 'object' || Array.isArray(obj) || obj === null) {
        return { error: `${field.label} must be a set of key/value pairs` };
      }
      return { value: JSON.stringify(obj) };
    }
    case 'select': {
      if (blank) return { value: null };
      const v = String(raw);
      // allowOther exists so a value already in the database stays editable
      // even when it is not one of the options we know about.
      if (!field.allowOther && field.options && !field.options.includes(v)) {
        return { error: `${field.label} must be one of: ${field.options.join(', ')}` };
      }
      return { value: v };
    }
    default:
      return { value: blank ? (field.blankAs ?? null) : String(raw) };
  }
}

// Shape a stored row for the editor: JSON columns come back as real values so
// the form does not have to know they were ever text.
export function decodeRow(cat, row) {
  const out = { id: row.id };
  for (const f of cat.fields) {
    const v = row[f.name];
    if (f.type === 'systems') out[f.name] = v ? safeParse(v, []) : null;
    else if (f.type === 'kv') out[f.name] = v ? safeParse(v, {}) : {};
    else out[f.name] = v;
  }
  if (cat.hasSource) out.source = row.source;
  return out;
}

function safeParse(text, fallback) {
  try { return JSON.parse(text); } catch { return fallback; }
}
