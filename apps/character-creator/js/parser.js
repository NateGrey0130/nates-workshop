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

// ---------- scalar helpers ----------

function stripComment(line) {
  let inQuote = null;
  for (let i = 0; i < line.length; i++) {
    const ch = line[i];
    if (inQuote) {
      if (ch === inQuote) inQuote = null;
    } else if (ch === '"' || ch === "'") {
      inQuote = ch;
    } else if (ch === '#') {
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

function toLines(text) {
  const lines = [];
  for (const raw of text.split(/\r?\n/)) {
    const stripped = stripComment(raw);
    if (stripped.trim() === '') continue;
    lines.push({ indent: stripped.length - stripped.trimStart().length, text: stripped.trim() });
  }
  return lines;
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
    if (val !== '') {
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
    for (const s of data.skills.occ_skills || []) {
      if (!s || typeof s !== 'object' || !s.name) errors.push('skills.occ_skills entries need a name');
      else if (typeof s.base !== 'number') warnings.push(`occ_skill "${s.name}" has no numeric base %`);
    }
    const related = data.skills.occ_related_skills;
    if (related && typeof related.count !== 'number') errors.push('skills.occ_related_skills.count must be a number');
    const secondary = data.skills.secondary_skills;
    if (secondary && typeof secondary.count !== 'number') errors.push('skills.secondary_skills.count must be a number');
  }
  for (const eq of data.equipment_starting || []) {
    if (!eq || typeof eq !== 'object' || !eq.item_id) errors.push('equipment_starting entries need an item_id');
  }
  for (const lp of data.level_progression || []) {
    if (!lp || typeof lp !== 'object' || typeof lp.level !== 'number') {
      errors.push('level_progression entries need a numeric level');
    }
  }

  const sections = parseBodySections(fm[2]);
  data.sections = sections;
  data.lore = sections['lore'] ?? null;
  data.gm_notes = sections['gm notes'] ?? null;
  if (!data.lore) warnings.push('No ## Lore section in body');

  return { ok: errors.length === 0, data, errors, warnings };
}
