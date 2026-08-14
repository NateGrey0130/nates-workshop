// Cross-references an extracted class against the live catalogs, and creates
// stub rows for anything it references that does not exist yet.
//
// All four catalogs (items, skills, spells, psionic powers) live in D1, so a
// stub goes live immediately with no redeploy. Stubs carry the bare minimum —
// a name and whatever category can be inferred — and are flagged so they are
// easy to find and fill in later.

import { isChoiceGroup } from '../../../../apps/character-creator/js/parser.js';

const norm = (s) => String(s ?? '').trim().toLowerCase();

// Every skill name the class references: fixed occ_skills plus every option
// inside an enumerated choice-group (any of them could be picked, so all must
// exist). Category-based groups resolve against the catalog at pick time.
export function referencedSkills(data) {
  const names = [];
  for (const s of data.skills?.occ_skills || []) {
    if (isChoiceGroup(s)) {
      for (const opt of s.from || []) names.push(typeof opt === 'string' ? opt : opt?.name);
    } else if (s?.name) {
      names.push(s.name);
    }
  }
  return names.filter(Boolean);
}

const nameList = (arr) => (arr || [])
  .map((x) => (typeof x === 'string' ? x : x?.name))
  .filter(Boolean);

// Looked up in batches: the name list comes from model-extracted class data and
// is effectively unbounded, while D1 caps bound parameters per query.
const LOOKUP_BATCH = 50;

async function missingFrom(env, table, column, names) {
  const wanted = [...new Set(names)];
  if (!wanted.length) return [];
  const known = new Set();
  for (let i = 0; i < wanted.length; i += LOOKUP_BATCH) {
    const batch = wanted.slice(i, i + LOOKUP_BATCH);
    const placeholders = batch.map(() => '?').join(',');
    const { results } = await env.DB
      .prepare(`SELECT ${column} AS key FROM ${table} WHERE ${column} IN (${placeholders})`)
      .bind(...batch).all();
    for (const r of results) known.add(norm(r.key));
  }
  return wanted.filter((w) => !known.has(norm(w)));
}

export async function crossReference(env, requestUrl, data) {
  const [items, skills, spells, psionics] = await Promise.all([
    missingFrom(env, 'gear', 'slug', (data.equipment_starting || []).map((e) => e?.item_id).filter(Boolean)),
    missingFrom(env, 'skills', 'name', referencedSkills(data)),
    missingFrom(env, 'spells', 'name', nameList(data.magic?.spells)),
    missingFrom(env, 'psionic_powers', 'name', nameList(data.psionics?.powers)),
  ]);
  return { items, skills, spells, psionics };
}

// ─── stub inference ───
// Best-effort categories from names, so created entries land closer to usable
// than a wall of TODOs. Percentile-less families correctly carry base 0.
const SKILL_PATTERNS = [
  [/^w\.?p\.?\b/i, 'Weapon Proficiencies', false],
  [/^hand to hand/i, 'Physical', false],
  [/^(boxing|wrestling|gymnastics|acrobatics|running|climbing|swimming|prowl|athletics|body building)/i, 'Physical', true],
  [/^language\b|^literacy\b/i, 'Communications', true],
  [/^(dance|sing|play musical|cook|sewing|fish|brewing|housekeeping|wardrobe)/i, 'Domestic', true],
  [/^radio\b|^cryptography|^laser communications/i, 'Communications', true],
  [/^pilot:/i, 'Pilot', true],
  [/^(read sensory|weapon systems|navigation)/i, 'Pilot Related', true],
  [/^(basic|advanced) math|^astronomy|^biology|^chemistry/i, 'Science', true],
  [/^(detect|intelligence|escape artist|disguise|tracking|surveillance)/i, 'Espionage', true],
  [/^(wilderness|land navigation|track|identify plants|skin and prepare)/i, 'Wilderness', true],
  [/^(camouflage|demolitions|field armorer|recognize weapon)/i, 'Military', true],
  [/^horsemanship/i, 'Horsemanship', true],
  [/^lore:|^computer|^art\b/i, 'Technical', true],
];

const PSIONIC_PATTERNS = [
  [/^(exorcism|bio-manipulation|electrokinesis|hydrokinesis|pyrokinesis|telekinetic|psi-sword|psi-shield|mind bolt|group mind)/i, 'Super'],
  [/^(sense|see |detect|presence|clairvoyance|telepathy|empathy|object read|sixth sense|read dedication|total recall)/i, 'Sensitive'],
  [/^(heal|bio-regenerate|deaden pain|induce sleep|psychic (purification|diagnosis|surgery)|stop bleeding)/i, 'Healing'],
  [/^(impervious|levitation|mind block|nightvision|resist|summon inner strength|death trance|alter aura|telekinesis|ectoplasm|float|swim|breathe)/i, 'Physical'],
];

const matchCategory = (patterns, name) => {
  for (const [re, category] of patterns) if (re.test(name)) return category;
  return null;
};

const titleize = (slug) => String(slug).split('-')
  .map((w) => (w ? w[0].toUpperCase() + w.slice(1) : w)).join(' ');

/**
 * Inserts stub rows for everything missing. Returns what was created, grouped
 * by catalog, so the UI can report it. INSERT OR IGNORE keeps this safe against
 * a concurrent import creating the same name.
 */
export function buildStubStatements(env, missing, { system, sourceBook }) {
  const created = { items: [], skills: [], spells: [], psionics: [] };
  const statements = [];

  for (const slug of missing.items) {
    created.items.push({ slug, name: titleize(slug) });
    statements.push(env.DB.prepare(
      `INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
       VALUES (?, ?, ?, ?, ?)`
    ).bind(slug, titleize(slug), system, 'STUB — created by class import, needs stats', sourceBook ?? null));
  }
  for (const name of missing.skills) {
    const category = matchCategory(SKILL_PATTERNS, name);
    created.skills.push({ name, category });
    statements.push(env.DB.prepare(
      'INSERT OR IGNORE INTO skills (name, category, base, per_level, source) VALUES (?, ?, 0, 0, ?)'
    ).bind(name, category, 'import'));
  }
  for (const name of missing.spells) {
    created.spells.push({ name });
    statements.push(env.DB.prepare(
      'INSERT OR IGNORE INTO spells (name, level, ppe, source) VALUES (?, 0, 0, ?)'
    ).bind(name, 'import'));
  }
  for (const name of missing.psionics) {
    const category = matchCategory(PSIONIC_PATTERNS, name);
    created.psionics.push({ name, category });
    statements.push(env.DB.prepare(
      'INSERT OR IGNORE INTO psionic_powers (name, category, isp, source) VALUES (?, ?, 0, ?)'
    ).bind(name, category, 'import'));
  }

  return { created, statements };
}
