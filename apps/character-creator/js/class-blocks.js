// Editing one frontmatter block without touching the rest of the file.
//
// A classic script, like class-template.js, because import.js is one. Exposes
// one global: `classBlocks`.
//
// WHY NOT A FORM OVER THE WHOLE FILE. A form has to write its edits back, and
// regenerating the frontmatter wholesale would destroy the template's comments,
// the key order and any block scalars — the comments being most of what makes
// a hand-written class approachable. So this replaces exactly one top-level
// block and leaves every byte outside it alone.
//
// Comments INSIDE an edited block do not survive, because the block is rebuilt
// from its parsed value. That is the trade, and it is the right way round: the
// blocks worth a form (`bonuses`, `variants`) are structure, and the blocks
// worth comments are the ones this never touches.
//
// Rebuilding from the PARSED object also means fields the form does not show
// still survive a save — a variant's attribute_dice is written back untouched
// even though nothing here edits it.

(function (global) {
  // ─── emitting ───

  // Enough YAML for the shapes these blocks actually hold: nested maps, arrays
  // of maps, strings and numbers. Deliberately not a general serialiser — it is
  // only ever handed a subtree that came out of parseYaml.
  function emit(value, indent) {
    const pad = ' '.repeat(indent);

    if (Array.isArray(value)) {
      if (!value.length) return ' []';
      return '\n' + value.map((v) => {
        if (v !== null && typeof v === 'object' && !Array.isArray(v)) {
          // A map in a list: the first key rides on the dash.
          const inner = emit(v, indent + 2).replace(/^\n/, '');
          return `${pad}- ${inner.slice(indent + 2)}`;
        }
        return `${pad}- ${scalar(v)}`;
      }).join('\n');
    }

    if (value !== null && typeof value === 'object') {
      const keys = Object.keys(value);
      if (!keys.length) return ' {}';
      return '\n' + keys.map((k) => `${pad}${k}:${emit(value[k], indent + 2)}`).join('\n');
    }

    return ' ' + scalar(value);
  }

  function scalar(v) {
    if (v === null || v === undefined) return 'null';
    if (typeof v === 'number' || typeof v === 'boolean') return String(v);
    const s = String(v);
    // Quote anything that would otherwise change meaning, and anything empty.
    return /^[\w][\w .%+\-/()&',:]*$/.test(s) && !/: /.test(s) && s.trim() === s && s !== ''
      ? (/^(true|false|null|~|\d|-)/.test(s) ? JSON.stringify(s) : s)
      : JSON.stringify(s);
  }

  // A whole top-level block, ready to splice in.
  function toYaml(key, value) {
    return `${key}:${emit(value, 2)}`;
  }

  // ─── locating ───

  const FM = /^(---\r?\n)([\s\S]*?)(\r?\n---)/;

  // Where a top-level key's block starts and ends inside the frontmatter.
  // A block runs from its key line to the next line that starts a top-level key
  // — column 0, not a comment, not a list item.
  function findBlock(frontmatter, key) {
    const lines = frontmatter.split('\n');
    const startsTopLevel = (l) => /^[A-Za-z_][\w-]*\s*:/.test(l);

    const start = lines.findIndex((l) => new RegExp(`^${key}\\s*:`).test(l));
    if (start < 0) return null;

    let end = lines.length;
    for (let i = start + 1; i < lines.length; i++) {
      if (startsTopLevel(lines[i])) { end = i; break; }
    }
    return { start, end, lines };
  }

  // The template ships `variants` and `bonuses` commented out, as worked
  // examples of shapes nobody remembers. Writing a real block would otherwise
  // append it and leave the example behind, so the file ends up appearing to
  // define the same key twice — one commented, one not. Replacing the example
  // is what you meant, and it has served its purpose by then.
  //
  // Matched only as a whole run of comment lines starting at `# key:`, so an
  // ordinary explanatory comment that happens to mention the key is safe.
  function findCommentedBlock(frontmatter, key) {
    const lines = frontmatter.split('\n');
    const start = lines.findIndex((l) => new RegExp(`^#\\s*${key}\\s*:`).test(l));
    if (start < 0) return null;

    let end = start + 1;
    while (end < lines.length && /^#/.test(lines[end])) end++;
    return { start, end, lines };
  }

  // ─── the two operations ───

  function read(markdown, key) {
    const fm = FM.exec(markdown || '');
    if (!fm) return null;
    const found = findBlock(fm[2], key);
    if (!found) return null;
    return found.lines.slice(found.start, found.end).join('\n');
  }

  // Replace `key`'s block, or add it just before the end of the frontmatter when
  // it is absent. A null/empty value removes the block entirely.
  function write(markdown, key, value) {
    const fm = FM.exec(markdown || '');
    if (!fm) return markdown;

    const isEmpty = value === null || value === undefined
      || (Array.isArray(value) && !value.length)
      || (typeof value === 'object' && !Array.isArray(value) && !Object.keys(value).length);

    const found = findBlock(fm[2], key) || findCommentedBlock(fm[2], key);
    let lines;
    if (found) {
      lines = found.lines.slice();
      lines.splice(found.start, found.end - found.start, ...(isEmpty ? [] : toYaml(key, value).split('\n')));
    } else {
      if (isEmpty) return markdown;
      lines = fm[2].split('\n').concat(toYaml(key, value).split('\n'));
    }

    const rebuilt = lines.join('\n');
    return markdown.slice(0, fm.index) + fm[1] + rebuilt + fm[3] + markdown.slice(fm.index + fm[0].length);
  }

  // ─── bonuses as a flat table ───
  //
  // A bonuses block is really a list of (level, group, key, value) tuples —
  // `at_level` is the same thing with a level attached. Flattening it makes one
  // small table cover base bonuses AND level-earned ones, instead of a nested
  // editor for each group and a second one inside every at_level entry.

  function bonusesToRows(bonuses) {
    const rows = [];
    const take = (src, level) => {
      for (const group of ['attributes', 'combat', 'saves']) {
        for (const [k, v] of Object.entries(src?.[group] || {})) rows.push({ level, group, key: k, value: v });
      }
    };
    take(bonuses, null);
    for (const step of bonuses?.at_level || []) take(step, step.level);
    return rows;
  }

  function rowsToBonuses(rows) {
    const out = {};
    const byLevel = new Map();
    for (const r of rows) {
      if (!r.group || !r.key || !Number.isFinite(r.value)) continue;
      if (r.level == null) {
        (out[r.group] ||= {})[r.key] = r.value;
      } else {
        const step = byLevel.get(r.level) || { level: r.level };
        (step[r.group] ||= {})[r.key] = r.value;
        byLevel.set(r.level, step);
      }
    }
    const levels = [...byLevel.keys()].sort((a, b) => a - b);
    if (levels.length) out.at_level = levels.map((l) => byLevel.get(l));
    return out;
  }

  global.classBlocks = { read, write, toYaml, bonusesToRows, rowsToBonuses };
})(globalThis);
