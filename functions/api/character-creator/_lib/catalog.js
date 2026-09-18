// Cross-references an extracted class against the live catalogs, and creates
// stub rows for anything it references that does not exist yet.
//
// All five catalogs (skills, spells, psionic powers, gear, enchantments) live
// in D1, so a
// stub goes live immediately with no redeploy. Stubs carry the bare minimum —
// a name and whatever category can be inferred — and are flagged so they are
// easy to find and fill in later.

import { isChoiceGroup, isGearChoice } from '../../../../apps/character-creator/js/parser.js';
import { resolveKeys } from './catalog-redirects.js';

const norm = (s) => String(s ?? '').trim().toLowerCase();

// The games a skills.systems array may name (parser.js VALID_SYSTEMS).
const SKILL_GAMES = ['rifts', 'palladium-fantasy', 'nightbane', 'heroes-unlimited'];

// Every skill name the class references: fixed occ_skills plus every option
// inside an enumerated choice-group (any of them could be picked, so all must
// exist). Category-based groups resolve against the catalog at pick time.
function namesFromEntries(entries) {
  const names = [];
  for (const s of entries || []) {
    if (isChoiceGroup(s)) {
      for (const opt of s.from || []) names.push(typeof opt === 'string' ? opt : opt?.name);
    } else if (s?.name) {
      names.push(s.name);
    }
  }
  return names.filter(Boolean);
}

function referencedSkills(data) {
  return namesFromEntries(data.skills?.occ_skills);
}

// Every skill name inside an MOS option, collected SEPARATELY from the ones
// above and reported on its own, which is the whole point of the split.
//
// `parser.js` validates an MOS option's skills through the same
// `validateSkillEntries` as `occ_skills`, so they are the same shape and can be
// walked by the same helper - but they must not be STUBBED like them. A missing
// `occ_skills` row is usually a skill the book defines and the catalog lacks,
// which a stub row is the right answer to. A missing MOS name is far more
// likely to be a typo, and stubbing a typo creates a permanent catalog row
// nobody meant, spelled the wrong way, that the class then resolves against
// happily. Report it and let a person decide (BOOK-INGEST-AUDIT F27).
export function referencedMosSkills(data) {
  const names = [];
  for (const opt of data.skills?.mos?.options || []) {
    names.push(...namesFromEntries(opt?.skills));
  }
  return names;
}

// Every gear slug the class references: fixed entries plus every option inside
// a choice. All the options must exist, the same reasoning as skill groups —
// any one of them could be the one picked.
export function referencedGear(data) {
  const slugs = [];
  for (const eq of data.equipment_starting || []) {
    if (isGearChoice(eq)) slugs.push(...(eq.from || []));
    else if (eq?.item_id) slugs.push(eq.item_id);
  }
  return slugs.filter(Boolean);
}

const nameList = (arr) => (arr || [])
  .map((x) => (typeof x === 'string' ? x : x?.name))
  .filter(Boolean);

// Looked up in batches: the name list comes from model-extracted class data and
// is effectively unbounded, while D1 caps bound parameters per query.
const LOOKUP_BATCH = 50;

async function missingFrom(env, catalogKey, table, column, names) {
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

  const missing = wanted.filter((w) => !known.has(norm(w)));
  if (!missing.length) return [];

  // A key that redirects is not missing — it names a row that was merged away
  // or renamed, and still resolves. Creating a stub for it would put back
  // exactly what the merge removed, which is how a merge used to come undone
  // the next time its class was re-imported.
  const redirects = await resolveKeys(env, catalogKey, missing);
  return missing.filter((m) => !redirects.has(norm(m)));
}

// A category restriction names skills by hand — "Espionage: Escape Artist only",
// "Medical: any except cybernetics". A name matching no catalog row does not
// fail loudly: `categoryAllows` compares literal names, so an unmatched `except`
// excludes NOTHING and an unmatched `only` offers nothing. Both are silent, and
// the `except` direction fails open, which is the dangerous way round.
//
// Harmless for a skill not imported yet, and indistinguishable from a name the
// catalog spells differently — which is the common case. The Godling R.C.C.
// forbids robots, power armor and cybernetics; the catalog calls those "Robots
// and Power Armor", "Robot Combat: Basic" and "M.D. in Cybernetics", so every
// one of those exclusions quietly did nothing and the class offered skills the
// book forbids.
//
// Redirects are deliberately NOT consulted here, unlike `missingFrom`.
// `categoryAllows` does a literal name comparison, so a key that resolves only
// through a redirect still will not match, and reporting it as fine would be a
// lie about what the picker does.
// Split from the lookup so the collecting half is testable without a database.
export function restrictionNames(data) {
  const wanted = [];
  // `skill_programs` is walked for the same reason as the other two, and needs
  // it more: a program's `only` list is the only thing between a chosen
  // category and its entire contents, and an unmatched `only` fails CLOSED -
  // the category then admits nothing. A typo there grants a player NOTHING,
  // silently, which is the direction no report catches (F23(b)).
  //
  // The `_prefix` forms are deliberately not collected. They name a family
  // rather than a row, so "does a row have this name" is the wrong question and
  // would report every prefix as a missing skill.
  for (const group of [data?.skills?.occ_related_skills, data?.skills?.secondary_skills,
                       data?.skills?.skill_programs]) {
    for (const c of group?.categories || []) {
      // A bare string is "any skill in this category" and names nothing.
      if (!c || typeof c !== 'object') continue;
      for (const kind of ['only', 'except']) {
        for (const name of c[kind] || []) wanted.push({ category: c.name, kind, name });
      }
    }
  }
  // The same restriction keys, one level deeper, inside an MOS option's own
  // choice groups. This was NOT assumed to be in the same blind spot - it was
  // measured, by putting a name no skill row has inside an MOS option's
  // `categories[].only` and watching class-check report `restrictions ok`
  // (BOOK-INGEST-AUDIT F27). The consequence is the worse of the two
  // directions: an unmatched `only` fails CLOSED, so the option grants the
  // player nothing at all.
  for (const opt of data?.skills?.mos?.options || []) {
    for (const entry of opt?.skills || []) {
      for (const c of entry?.categories || []) {
        if (!c || typeof c !== 'object') continue;
        for (const kind of ['only', 'except']) {
          for (const name of c[kind] || []) {
            wanted.push({ category: `${opt.id || 'mos'}/${c.name}`, kind, name });
          }
        }
      }
    }
  }
  return wanted;
}

// Every spell or psionic power a class NAMES BY HAND, from every block that can
// carry a name - not just the two `crossReference` used to look at.
//
// `magic.spells` and `psionics.powers` are GRANTS, and a grant naming a row the
// catalog lacks is a visible gap by design. Everything below is a
// RESTRICTION - `spells_from`, `spell_lists`, `powers_from`, and the `from` on a
// starting group or a schedule entry - and a restriction naming nothing fails
// CLOSED: the list IS the gate, so the picker comes up short or empty and
// nothing anywhere says why. Same shape as an unmatched `only` on a skill
// program, and as `from_list` before RETRO-AUDIT R11.
//
// Walked inside an ABILITY OPTION's block too. That is where this book keeps
// them: an Alien's power category is a choice of six, and the Mystic option
// carries all forty-eight of its spells while the Psychic option carries
// thirty-three powers, one level below anything that used to be checked.
function namedPowerLists(block) {
  const out = [];
  if (!block || typeof block !== 'object') return out;
  for (const key of ['spells_from', 'powers_from', 'spells_per_level_from']) {
    out.push(...nameList(block[key]));
  }
  for (const key of ['spells_starting_groups', 'powers_starting_groups',
                     'spells_schedule', 'powers_schedule']) {
    for (const g of block[key] || []) out.push(...nameList(g?.from));
  }
  // `spell_lists` is a MAP of named lists a schedule entry draws from.
  for (const list of Object.values(block.spell_lists || {})) out.push(...nameList(list));
  return out;
}

// `granted` and `listed` are kept APART because only one of them may be
// stubbed. A grant naming an absent row is a row to create - the books cite
// spells ahead of their import and the Priest of Light does it deliberately. A
// LIST naming an absent row is a misspelling, and stubbing it would enshrine
// the misspelling as a catalog row that sorts before the file which would have
// created the real one.
function referencedPowers(data, key) {
  const blocks = [data?.[key]];
  for (const d of data?.special_abilities || []) {
    if (d && typeof d === 'object' && d[key]) blocks.push(d[key]);
  }
  const granted = [];
  const listed = [];
  for (const b of blocks) {
    if (!b) continue;
    granted.push(...nameList(b[key === 'magic' ? 'spells' : 'powers']));
    listed.push(...namedPowerLists(b));
  }
  // A name that is BOTH granted and listed is a grant; it is stubbable and
  // reporting it twice would read as two problems.
  const g = new Set(granted.map(norm));
  return { granted, listed: listed.filter((n) => !g.has(norm(n))) };
}

// Every super-ability name a class cites: granted outright, named on the
// block's own list, named by a starting group, and the same three one level
// deeper inside an ability option's block - which is where a Power Category
// keeps most of them, because its packages are ability choices.
//
// Collected separately from `magic.spells` and `psionics.powers` rather than
// folded in with them, because the consequence of a miss is different. A spell
// the catalog lacks is a row to create; a super ability the catalog lacks is a
// TRANSCRIPTION ERROR, since the whole of both books' ability lists is already
// imported. So these are reported and never stubbed - see crossReference.
function referencedSuperAbilities(data) {
  const blocks = [data?.super_abilities];
  for (const d of data?.special_abilities || []) {
    if (d && typeof d === 'object' && d.super_abilities) blocks.push(d.super_abilities);
  }
  const out = [];
  for (const b of blocks) {
    if (!b) continue;
    out.push(...nameList(b.abilities), ...nameList(b.abilities_from));
    for (const g of b.abilities_starting_groups || []) out.push(...nameList(g?.from));
    for (const g of b.abilities_schedule || []) out.push(...nameList(g?.from));
  }
  return out;
}

async function unresolvedRestrictions(env, data) {
  const wanted = restrictionNames(data);
  if (!wanted.length) return [];

  const names = [...new Set(wanted.map((w) => w.name))];
  const known = new Set();
  for (let i = 0; i < names.length; i += LOOKUP_BATCH) {
    const batch = names.slice(i, i + LOOKUP_BATCH);
    const { results } = await env.DB
      .prepare(`SELECT name FROM skills WHERE name IN (${batch.map(() => '?').join(',')})`)
      .bind(...batch).all();
    for (const r of results) known.add(norm(r.name));
  }
  return wanted.filter((w) => !known.has(norm(w.name)));
}



export async function crossReference(env, requestUrl, data) {
  const magicNames = referencedPowers(data, 'magic');
  const psiNames = referencedPowers(data, 'psionics');
  const [items, skills, spells, psionics, restrictions, mosSkills, superAbilities,
         spellLists, psionicLists]
    = await Promise.all([
      missingFrom(env, 'gear', 'gear', 'slug', referencedGear(data)),
      missingFrom(env, 'skills', 'skills', 'name', referencedSkills(data)),
      missingFrom(env, 'spells', 'spells', 'name', magicNames.granted),
      missingFrom(env, 'psionics', 'psionic_powers', 'name', psiNames.granted),
      unresolvedRestrictions(env, data),
      missingFrom(env, 'skills', 'skills', 'name', referencedMosSkills(data)),
      missingFrom(env, 'superAbilities', 'super_abilities', 'name',
                  referencedSuperAbilities(data)),
      missingFrom(env, 'spells', 'spells', 'name', magicNames.listed),
      missingFrom(env, 'psionics', 'psionic_powers', 'name', psiNames.listed),
    ]);
  // `mosSkills` is deliberately its own key rather than folded into `skills`.
  // Callers stub `missing.skills`; nothing should stub this one. See
  // referencedMosSkills above for why. `superAbilities` is the same posture for
  // a different reason: both books' ability lists are imported whole, so a name
  // that matches nothing is a misspelling and a stub would enshrine it.
  return { items, skills, spells, psionics, restrictions, mosSkills, superAbilities,
           spellLists, psionicLists };
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
  // Every stub records the class's `source_book` — the pages the NAME was read
  // on, which is the only claim a stub can honestly make. It has no stats yet,
  // so there is no equipment-chapter or spell-chapter page to cite instead,
  // and when the catalog importer later fills the row it overwrites this with
  // the pages the stat block is actually printed on.
  //
  // Gear did this from the start. Skills, spells and psionic powers did not
  // name the column at all, so 12 skills and 12 psionic powers in production
  // carry no provenance whatsoever — not a wrong book, none. Same value, same
  // reasoning, four catalogs.
  const book = sourceBook ?? null;

  for (const slug of missing.items) {
    created.items.push({ slug, name: titleize(slug) });
    statements.push(env.DB.prepare(
      `INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
       VALUES (?, ?, ?, ?, ?)`
    ).bind(slug, titleize(slug), system, 'STUB — created by class import, needs stats', book));
  }
  // A stub skill is tagged with the importing class's game. The class naming it
  // is the evidence zzzzzzzzzzzzzzzz-tag-skill-systems.sql tagged every other
  // row by, and an untagged row is offered to every game's picker - the leak
  // that file closed. A class with no recognised game leaves it NULL.
  const skillSystems = SKILL_GAMES.includes(system) ? JSON.stringify([system]) : null;
  for (const name of missing.skills) {
    const category = matchCategory(SKILL_PATTERNS, name);
    created.skills.push({ name, category });
    statements.push(env.DB.prepare(
      'INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book) VALUES (?, ?, 0, 0, ?, ?, ?)'
    ).bind(name, category, skillSystems, 'import', book));
  }
  for (const name of missing.spells) {
    created.spells.push({ name });
    statements.push(env.DB.prepare(
      'INSERT OR IGNORE INTO spells (name, level, ppe, source, source_book) VALUES (?, 0, 0, ?, ?)'
    ).bind(name, 'import', book));
  }
  for (const name of missing.psionics) {
    const category = matchCategory(PSIONIC_PATTERNS, name);
    created.psionics.push({ name, category });
    statements.push(env.DB.prepare(
      'INSERT OR IGNORE INTO psionic_powers (name, category, isp, source, source_book) VALUES (?, ?, 0, ?, ?)'
    ).bind(name, category, 'import', book));
  }

  return { created, statements };
}
