// RCC/OCC markdown parser — YAML frontmatter → structured data, body → lore sections.
// Zero dependencies; runs in the browser, Node, and Cloudflare Pages Functions.
//
// Supported YAML subset (all the class files need, nothing more):
//   - key: scalar          (strings, numbers, booleans; quoted or bare)
//   - key:                 (nested map or list on following lines, 2-space indent)
//   - - scalar             (list of scalars)
//   - - { k: v, k2: v2 }   (list of inline objects)
//   - - key: v             (list of maps in block form, 2-space indent)
//   - [a, "b", c]          (inline arrays)
//   - # comments

const VALID_SYSTEMS = ['rifts', 'palladium-fantasy'];
const VALID_CATEGORIES = ['rcc', 'occ'];

// YAML block scalar introducers: | and > with optional chomping/indent modifiers.
const BLOCK_SCALAR = /^[|>][-+]?\d*$/;

// A "pick N from this list" entry inside occ_skills, as opposed to a fixed skill.
// A choice-group has no name of its own — it is "pick N from these". A named
// entry that also carries `choose` is a fixed skill taken N times (e.g.
// "Play Musical Instrument, select two instruments"), not a group.
export function isChoiceGroup(entry) {
  return !!entry && typeof entry === 'object' && !entry.name &&
    (entry.choose !== undefined || entry.from !== undefined || entry.categories !== undefined);
}

// ─── class variants ───
//
// Several RCCs come in stages rather than as one statblock: a Dragon is a
// hatchling, then young, then adult, sharing lore, natural abilities and skills
// while differing in attribute dice, M.D.C. and what the class grants. Four
// unrelated class files means maintaining the shared 90% four times.
//
// A variant may override ONLY these. Skills, abilities, lore and equipment stay
// shared on purpose: a variant that could override anything is not a variant,
// it is a second class wearing the first one's name, and the inheritance would
// obscure rather than explain.
export const VARIANT_OVERRIDES = [
  'attribute_dice', 'attribute_requirements',
  'hit_points_base', 'sdc_base', 'mdc_base', 'ppe_base',
  'bonuses',
];

// The class as this variant plays it. Returns the class unchanged when there is
// no variant, so every caller can apply it unconditionally.
export function applyVariant(cls, variantId) {
  if (!cls || !variantId || !Array.isArray(cls.variants)) return cls;
  const v = cls.variants.find((x) => x?.id === variantId);
  if (!v) return cls;

  const out = { ...cls };
  for (const key of VARIANT_OVERRIDES) {
    if (v[key] !== undefined) out[key] = v[key];
  }
  // The variant's own name replaces the class's for display — "Dragon
  // Hatchling", not "Dragon" — while class_id keeps pointing at the one class.
  if (v.name) out.name = v.name;
  out.variant_id = v.id;
  return out;
}

function validateVariants(variants, errors, warnings) {
  if (!Array.isArray(variants)) {
    errors.push('variants must be a list');
    return;
  }
  if (!variants.length) warnings.push('variants is empty and will be ignored');

  const seen = new Set();
  for (const v of variants) {
    if (!v || typeof v !== 'object') { errors.push('variants entries must be objects'); continue; }
    if (typeof v.id !== 'string' || !v.id.trim()) { errors.push('variants entries need an id'); continue; }
    if (seen.has(v.id)) errors.push(`variants has two entries with id "${v.id}"`);
    seen.add(v.id);
    if (!v.name) warnings.push(`variant "${v.id}" has no name and will display as the class name`);
    if (v.bonuses) validateBonuses(v.bonuses, errors, warnings);

    // A field a variant cannot override would silently do nothing, which is
    // exactly the confusion this list exists to prevent.
    for (const key of Object.keys(v)) {
      if (key === 'id' || key === 'name' || VARIANT_OVERRIDES.includes(key)) continue;
      warnings.push(`variant "${v.id}" sets ${key}, which a variant cannot override — it will be ignored`);
    }
  }
}

// The attributes a class bonus may name. Anything else is a typo — a bonus
// filed under a key nothing reads would silently do nothing, which is the
// failure this whole block exists to prevent.
export const BONUS_ATTRS = ['IQ', 'ME', 'MA', 'PS', 'PP', 'PE', 'PB', 'Spd'];

// The three groups a bonus can land in. `combat` and `saves` deliberately do
// not enumerate their keys: both are open sets that derive.js grows, and a
// bonus to a key it has not heard of is better surfaced as a warning than
// rejected outright.
const BONUS_GROUPS = ['attributes', 'combat', 'saves'];

function validateBonusGroup(where, group, block, errors, warnings) {
  if (block === undefined || block === null) return;
  if (typeof block !== 'object' || Array.isArray(block)) {
    errors.push(`${where}.${group} must be a map of name to number`);
    return;
  }
  for (const [k, v] of Object.entries(block)) {
    if (typeof v !== 'number' || !Number.isFinite(v)) {
      errors.push(`${where}.${group}.${k} must be a number`);
    } else if (group === 'attributes' && !BONUS_ATTRS.includes(k)) {
      errors.push(`${where}.attributes.${k} is not an attribute (${BONUS_ATTRS.join(', ')})`);
    } else if (v === 0) {
      warnings.push(`${where}.${group}.${k} is 0 and will do nothing`);
    }
  }
}

export function validateBonuses(bonuses, errors, warnings) {
  if (typeof bonuses !== 'object' || Array.isArray(bonuses)) {
    errors.push('bonuses must be a map');
    return;
  }
  for (const g of BONUS_GROUPS) validateBonusGroup('bonuses', g, bonuses[g], errors, warnings);

  const known = new Set([...BONUS_GROUPS, 'at_level']);
  for (const k of Object.keys(bonuses)) {
    if (!known.has(k)) warnings.push(`bonuses.${k} is not a recognised group and will be ignored`);
  }

  // Bonuses earned later. Proposed in the level-up diff and applied on
  // confirmation, like every other level-up change.
  if (bonuses.at_level !== undefined) {
    if (!Array.isArray(bonuses.at_level)) {
      errors.push('bonuses.at_level must be a list');
      return;
    }
    for (const step of bonuses.at_level) {
      if (!step || typeof step !== 'object' || typeof step.level !== 'number') {
        errors.push('bonuses.at_level entries need a numeric level');
        continue;
      }
      if (step.level < 2) warnings.push(`bonuses.at_level level ${step.level} — level 1 belongs in bonuses itself`);
      for (const g of BONUS_GROUPS) {
        validateBonusGroup(`bonuses.at_level[${step.level}]`, g, step[g], errors, warnings);
      }
    }
  }
}

// The same idea for starting equipment, keyed on `item_id` rather than `name`.
//
// Books routinely say "one energy pistol of choice" where the format only had
// fixed item ids, and the workaround was a placeholder catalog row named after
// the category — `energy-pistol`, `vibro-blade`. Those are not items: no book
// entry will ever match them, so they sit in the catalog forever with no stats,
// and a character ends up holding a weapon that does not exist.
//
// There is no `categories` flavour here, unlike skills. Gear's `category` is
// weapon/armor/vehicle/gear — far too coarse to mean "any energy pistol" — so a
// gear choice enumerates its options explicitly.
export function isGearChoice(entry) {
  return !!entry && typeof entry === 'object' && !entry.item_id &&
    (entry.choose !== undefined || entry.from !== undefined);
}

// ---------- scalar helpers ----------

// Strips a trailing YAML comment. Per the YAML rule, `#` only starts a comment
// at the start of a line or after whitespace — so prose like "Note #7" and
// "don't" survive intact. Sourcebook text is full of both.
function stripComment(line) {
  let inQuote = null;
  for (let i = 0; i < line.length; i++) {
    const ch = line[i];
    if (inQuote) {
      if (ch === inQuote) inQuote = null;
    } else if (ch === '"' || ch === "'") {
      inQuote = ch;
    } else if (ch === '#' && (i === 0 || line[i - 1] === ' ' || line[i - 1] === '\t')) {
      return line.slice(0, i);
    }
  }
  return line;
}

function parseScalar(raw) {
  const s = raw.trim();
  if (s === '' || s === 'null' || s === '~') return null;
  if (s === 'true') return true;
  if (s === 'false') return false;
  if ((s[0] === '"' && s.endsWith('"')) || (s[0] === "'" && s.endsWith("'"))) {
    return s.slice(1, -1);
  }
  if (/^-?\d+$/.test(s)) return parseInt(s, 10);
  if (/^-?\d*\.\d+$/.test(s)) return parseFloat(s);
  return s;
}

// Split "a, b, {c: d}" on top-level commas (ignoring commas inside quotes/braces/brackets).
function splitTopLevel(s) {
  const parts = [];
  let depth = 0, inQuote = null, cur = '';
  for (const ch of s) {
    if (inQuote) {
      cur += ch;
      if (ch === inQuote) inQuote = null;
    } else if (ch === '"' || ch === "'") {
      cur += ch; inQuote = ch;
    } else if (ch === '{' || ch === '[') {
      cur += ch; depth++;
    } else if (ch === '}' || ch === ']') {
      cur += ch; depth--;
    } else if (ch === ',' && depth === 0) {
      parts.push(cur); cur = '';
    } else {
      cur += ch;
    }
  }
  if (cur.trim() !== '') parts.push(cur);
  return parts;
}

function splitKeyValue(s) {
  // First ':' not inside quotes/braces marks the key boundary.
  let depth = 0, inQuote = null;
  for (let i = 0; i < s.length; i++) {
    const ch = s[i];
    if (inQuote) {
      if (ch === inQuote) inQuote = null;
    } else if (ch === '"' || ch === "'") {
      inQuote = ch;
    } else if (ch === '{' || ch === '[') {
      depth++;
    } else if (ch === '}' || ch === ']') {
      depth--;
    } else if (ch === ':' && depth === 0) {
      return [s.slice(0, i).trim(), s.slice(i + 1).trim()];
    }
  }
  return null;
}

function parseInlineValue(s) {
  if (s[0] === '{' && s.endsWith('}')) {
    const obj = {};
    for (const part of splitTopLevel(s.slice(1, -1))) {
      const kv = splitKeyValue(part);
      if (kv) obj[kv[0]] = parseInlineValue(kv[1]);
    }
    return obj;
  }
  if (s[0] === '[' && s.endsWith(']')) {
    return splitTopLevel(s.slice(1, -1)).map((p) => parseInlineValue(p.trim()));
  }
  return parseScalar(s);
}

// ---------- block (indentation) parser ----------

// Each line keeps both its comment-stripped form (used for structure) and its
// raw form (used verbatim for block-scalar bodies, where a `#` is content, not
// a comment). `gap` records that a blank line preceded it, so paragraph breaks
// inside a block scalar survive.
//
// Known limitation: a block-scalar body line whose first non-space character is
// `#` is still treated as a comment and dropped.
function toLines(text) {
  const lines = [];
  let gap = false;
  for (const raw of text.split(/\r?\n/)) {
    if (raw.trim() === '') { gap = true; continue; }
    const stripped = stripComment(raw);
    if (stripped.trim() === '') continue; // comment-only line
    lines.push({
      indent: stripped.length - stripped.trimStart().length,
      text: stripped.trim(),
      rawText: raw.trimEnd(),
      rawIndent: raw.length - raw.trimStart().length,
      gap,
    });
    gap = false;
  }
  return lines;
}

// Joins a block-scalar body: `|` keeps line breaks, `>` folds to spaces, and a
// blank line in the source becomes a paragraph break in either style.
function joinBlock(body, style) {
  let out = '';
  body.forEach((line, idx) => {
    if (idx === 0) { out = line.text; return; }
    out += line.gap ? '\n\n' : (style === '|' ? '\n' : ' ');
    out += line.text;
  });
  return out.trim();
}

// Parses lines[start...] at exactly `indent`; returns [value, nextIndex].
function parseBlock(lines, start, indent) {
  if (lines[start].text.startsWith('- ') || lines[start].text === '-') {
    return parseList(lines, start, indent);
  }
  return parseMap(lines, start, indent);
}

function parseMap(lines, start, indent) {
  const map = {};
  let i = start;
  while (i < lines.length && lines[i].indent === indent && !lines[i].text.startsWith('- ')) {
    const kv = splitKeyValue(lines[i].text);
    if (!kv) throw new Error(`Expected "key: value" at: "${lines[i].text}"`);
    const [key, val] = kv;
    i++;
    if (BLOCK_SCALAR.test(val)) {
      // `key: |` / `key: >` — long free text on indented lines. The body is
      // taken raw: sourcebook prose is full of `#` and apostrophes, and none of
      // it is YAML syntax.
      const body = [];
      let baseIndent = null;
      while (i < lines.length && lines[i].indent > indent) {
        const line = lines[i];
        if (baseIndent === null) baseIndent = line.rawIndent;
        body.push({ text: line.rawText.slice(Math.min(baseIndent, line.rawIndent)), gap: line.gap });
        i++;
      }
      map[key] = joinBlock(body, val[0]);
    } else if (val !== '') {
      map[key] = parseInlineValue(val);
    } else if (i < lines.length && lines[i].indent > indent) {
      const [child, next] = parseBlock(lines, i, lines[i].indent);
      map[key] = child;
      i = next;
    } else {
      map[key] = null;
    }
  }
  return [map, i];
}

function parseList(lines, start, indent) {
  const list = [];
  let i = start;
  while (i < lines.length && lines[i].indent === indent && (lines[i].text.startsWith('- ') || lines[i].text === '-')) {
    const rest = lines[i].text === '-' ? '' : lines[i].text.slice(2).trim();
    const kv = rest === '' || rest[0] === '{' || rest[0] === '[' ? null : splitKeyValue(rest);
    if (kv) {
      // Block-form map item: "- key: v" plus continuation lines indented past the dash.
      // The first pair is re-injected at the continuation indent (dash + 2 spaces).
      const item = [{ indent: indent + 2, text: rest }];
      i++;
      while (i < lines.length && lines[i].indent > indent) {
        item.push(lines[i]);
        i++;
      }
      const [child] = parseMap(item, 0, indent + 2);
      list.push(child);
    } else {
      list.push(rest === '' ? null : parseInlineValue(rest));
      i++;
    }
  }
  return [list, i];
}

export function parseYaml(text) {
  const lines = toLines(text);
  if (lines.length === 0) return {};
  const [value] = parseBlock(lines, 0, lines[0].indent);
  return value;
}

// ---------- class file parser ----------

// Splits the markdown body into { "lore": "...", "gm notes": "..." } keyed by lowercased ## heading.
function parseBodySections(body) {
  const sections = {};
  const matches = [...body.matchAll(/^##\s+(.+)$/gm)];
  for (let i = 0; i < matches.length; i++) {
    const startIdx = matches[i].index + matches[i][0].length;
    const endIdx = i + 1 < matches.length ? matches[i + 1].index : body.length;
    sections[matches[i][1].trim().toLowerCase()] = body.slice(startIdx, endIdx).trim();
  }
  return sections;
}

/**
 * Parse one RCC/OCC markdown file.
 * Returns { ok, data, errors, warnings }. `data` is null only if the file has no
 * valid frontmatter block at all; otherwise it holds whatever parsed, plus:
 *   data.lore, data.gm_notes  — from ## Lore / ## GM Notes body sections
 *   data.sections             — all body sections keyed by lowercased heading
 */
export function parseClassMarkdown(text) {
  const errors = [];
  const warnings = [];

  const fm = text.match(/^---\r?\n([\s\S]*?)\r?\n---\s*\r?\n?([\s\S]*)$/);
  if (!fm) {
    return { ok: false, data: null, errors: ['No YAML frontmatter block found (--- ... ---)'], warnings };
  }

  let data;
  try {
    data = parseYaml(fm[1]);
  } catch (e) {
    return { ok: false, data: null, errors: ['Frontmatter parse error: ' + e.message], warnings };
  }

  // Required fields
  for (const field of ['id', 'name', 'system', 'source_book', 'category']) {
    if (data[field] == null || data[field] === '') errors.push(`Missing required field: ${field}`);
  }
  if (data.id != null && !/^[a-z0-9][a-z0-9-]*$/.test(String(data.id))) {
    errors.push(`id must be a kebab-case slug, got: ${data.id}`);
  }
  if (data.system != null && !VALID_SYSTEMS.includes(data.system)) {
    errors.push(`system must be one of ${VALID_SYSTEMS.join(' | ')}, got: ${data.system}`);
  }
  if (data.category != null && !VALID_CATEGORIES.includes(data.category)) {
    errors.push(`category must be one of ${VALID_CATEGORIES.join(' | ')}, got: ${data.category}`);
  }

  // Shape checks on optional structures
  if (data.skills) {
    // An occ_skills entry is either a fixed skill ({name, base, per_level}) or a
    // choice-group ({choose, from: [...]}) — some classes bundle "pick N of
    // these" into the required list itself. Both may carry a free-text `note`
    // for conditional substitutions (advisory only, never enforced).
    for (const s of data.skills.occ_skills || []) {
      if (!s || typeof s !== 'object') { errors.push('skills.occ_skills entries must be objects'); continue; }
      if (isChoiceGroup(s)) {
        // Two flavours: an enumerated `from` list, or `categories` when the book
        // says "any N skills from <category>" (e.g. "two piloting skills of choice").
        if (typeof s.choose !== 'number' || s.choose < 1) errors.push('occ_skills choice-group needs a numeric choose >= 1');
        const hasFrom = Array.isArray(s.from) && s.from.length > 0;
        const hasCats = Array.isArray(s.categories) && s.categories.length > 0;
        if (!hasFrom && !hasCats) {
          errors.push('occ_skills choice-group needs a non-empty from list or categories list');
        } else if (hasFrom && !hasCats && s.choose > s.from.length) {
          errors.push(`occ_skills choice-group asks for ${s.choose} of only ${s.from.length} options`);
        }
      } else if (!s.name) {
        errors.push('skills.occ_skills entries need a name (or choose/from for a choice-group)');
      } else if (typeof s.base !== 'number') {
        warnings.push(`occ_skill "${s.name}" has no numeric base %`);
      }
    }
    const related = data.skills.occ_related_skills;
    if (related) {
      if (typeof related.count !== 'number') errors.push('skills.occ_related_skills.count must be a number');
      // Optional staged picks: [{ level, count }] granted beyond the starting
      // count. Stored for future use — the leveling flow does not act on it yet.
      for (const step of related.schedule || []) {
        if (!step || typeof step.level !== 'number' || typeof step.count !== 'number') {
          errors.push('occ_related_skills.schedule entries need numeric level and count');
        }
      }
    }
    const secondary = data.skills.secondary_skills;
    if (secondary && typeof secondary.count !== 'number') errors.push('skills.secondary_skills.count must be a number');
  }
  for (const eq of data.equipment_starting || []) {
    if (!eq || typeof eq !== 'object') { errors.push('equipment_starting entries must be objects'); continue; }
    if (isGearChoice(eq)) {
      if (typeof eq.choose !== 'number' || eq.choose < 1) {
        errors.push('equipment_starting choice needs a numeric choose >= 1');
      }
      if (!Array.isArray(eq.from) || !eq.from.length) {
        errors.push('equipment_starting choice needs a non-empty from list of item slugs');
      } else if (eq.from.some((s) => typeof s !== 'string' || !s.trim())) {
        errors.push('equipment_starting choice `from` must be item slugs');
      } else if (eq.choose > eq.from.length) {
        errors.push(`equipment_starting choice asks for ${eq.choose} of only ${eq.from.length} options`);
      }
    } else if (!eq.item_id) {
      errors.push('equipment_starting entries need an item_id (or choose/from for a choice)');
    }
  }
  for (const lp of data.level_progression || []) {
    if (!lp || typeof lp !== 'object' || typeof lp.level !== 'number') {
      errors.push('level_progression entries need a numeric level');
    }
  }

  // What a class GRANTS mechanically, as opposed to level_progression.grants,
  // which is free text for display. A Dragon's "+2 to P.S." and "+1 attack per
  // melee at level 5" were prose that nothing could act on; this is where a
  // number goes so the sheet can actually add it up.
  if (data.bonuses) validateBonuses(data.bonuses, errors, warnings);
  if (data.variants !== undefined) validateVariants(data.variants, errors, warnings);

  const sections = parseBodySections(fm[2]);
  data.sections = sections;
  data.lore = sections['lore'] ?? null;
  data.gm_notes = sections['gm notes'] ?? null;
  if (!data.lore) warnings.push('No ## Lore section in body');

  return { ok: errors.length === 0, data, errors, warnings };
}
