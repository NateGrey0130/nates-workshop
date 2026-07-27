// Cross-references an extracted class against the live catalogs, so the import
// review can show what it references that doesn't exist yet.
//
// Items live in D1 (a stub row can go live immediately). Skills, spells, and
// psionic powers are static JSON shipped with the deploy, so those can only be
// surfaced as snippets to merge by hand.

import { isChoiceGroup } from '../../../../apps/character-creator/js/parser.js';

const DATA_PATH = '/apps/character-creator/data/';

async function loadJson(env, requestUrl, file) {
  const res = await env.ASSETS.fetch(new URL(DATA_PATH + file, requestUrl));
  if (!res.ok) return null;
  return res.json().catch(() => null);
}

const norm = (s) => String(s ?? '').trim().toLowerCase();

// Every skill name the class references: fixed occ_skills plus every option
// inside a choice-group (any of them could be picked, so all must exist).
export function referencedSkills(data) {
  const names = [];
  for (const s of data.skills?.occ_skills || []) {
    if (isChoiceGroup(s)) {
      // Category-based groups resolve against the catalog at pick time, so only
      // explicitly named options are checked for existence here.
      for (const opt of s.from || []) names.push(typeof opt === 'string' ? opt : opt?.name);
    } else if (s?.name) {
      names.push(s.name);
    }
  }
  return names.filter(Boolean);
}

export async function crossReference(env, requestUrl, data) {
  const missing = { items: [], skills: [], spells: [], psionics: [] };

  // Items — D1, matched on slug
  const slugs = (data.equipment_starting || []).map((e) => e?.item_id).filter(Boolean);
  if (slugs.length) {
    const placeholders = slugs.map(() => '?').join(',');
    const { results } = await env.DB
      .prepare(`SELECT slug FROM items WHERE slug IN (${placeholders})`)
      .bind(...slugs).all();
    const known = new Set(results.map((r) => norm(r.slug)));
    missing.items = [...new Set(slugs.filter((s) => !known.has(norm(s))))];
  }

  const [skillsCat, spellsCat, psiCat] = await Promise.all([
    loadJson(env, requestUrl, 'skills.json'),
    loadJson(env, requestUrl, 'spells.json'),
    loadJson(env, requestUrl, 'psionics.json'),
  ]);

  if (skillsCat?.skills) {
    const known = new Set(skillsCat.skills.map((s) => norm(s.name)));
    missing.skills = [...new Set(referencedSkills(data).filter((n) => !known.has(norm(n))))];
  }
  // Classes don't normally name individual spells/powers, but an extraction may
  // surface them (e.g. magic.spells or psionics.powers); check whatever is there.
  if (spellsCat?.spells) {
    const known = new Set(spellsCat.spells.map((s) => norm(s.name)));
    const refs = (data.magic?.spells || []).map((s) => (typeof s === 'string' ? s : s?.name)).filter(Boolean);
    missing.spells = [...new Set(refs.filter((n) => !known.has(norm(n))))];
  }
  if (psiCat?.powers) {
    const known = new Set(psiCat.powers.map((p) => norm(p.name)));
    const refs = (data.psionics?.powers || []).map((p) => (typeof p === 'string' ? p : p?.name)).filter(Boolean);
    missing.psionics = [...new Set(refs.filter((n) => !known.has(norm(n))))];
  }

  return missing;
}

// Best-effort category from the skill name, so snippets land closer to
// mergeable than a wall of TODOs. Percentile-less families (W.P.s, hand to
// hand, physical training) correctly carry base 0.
const SKILL_PATTERNS = [
  [/^w\.?p\.?\b/i, 'Weapon Proficiencies', false],
  [/^hand to hand/i, 'Physical', false],
  [/^(boxing|wrestling|gymnastics|acrobatics|running|climbing|swimming|prowl|athletics|body building)/i, 'Physical', true],
  [/^language\b|^literacy\b/i, 'Communications', true],
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

function inferSkill(name) {
  for (const [re, category, percentile] of SKILL_PATTERNS) {
    if (!re.test(name)) continue;
    // Non-percentile families (W.P.s, hand to hand) are complete at base 0;
    // percentile skills still need their real numbers from the skill table.
    return percentile
      ? { name, category, base: 0, per_level: 0, _note: 'set base/per_level from the skill table' }
      : { name, category, base: 0, per_level: 0 };
  }
  return { name, category: 'TODO', base: 0, per_level: 0, _note: 'set category and base/per_level' };
}

// Ready-to-merge JSON snippets for the static catalogs. Categories are inferred
// where possible; base/per_level still need the real numbers from the skill
// table before committing.
export function buildSnippets(missing) {
  const snippets = {};
  if (missing.skills.length) {
    snippets['data/skills.json'] = missing.skills.map(inferSkill);
  }
  if (missing.spells.length) {
    snippets['data/spells.json'] = missing.spells.map((name) => ({ name, level: 0, ppe: 0 }));
  }
  if (missing.psionics.length) {
    snippets['data/psionics.json'] = missing.psionics.map((name) => ({ name, category: 'TODO', isp: 0 }));
  }
  return snippets;
}
