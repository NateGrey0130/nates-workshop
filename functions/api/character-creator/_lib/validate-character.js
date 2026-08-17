// Server-side check of the rules the wizard enforces.
//
// The wizard has always enforced skill counts, category restrictions and
// attribute minimums; the server checked shape, ownership and campaign
// existence only. That is fine for a friends-only app behind Access, but it is
// not a boundary — a client bug writes an illegal character and nothing notices.
//
// Deliberately narrow. It checks what a PLAYER CHOOSES:
//
//   - how many related and secondary skills they took
//   - whether those skills are in the categories the class allows
//   - whether their attributes meet the class's minimums
//   - whether choice-groups in occ_skills look satisfied (advisory only)
//
// It does NOT check the class's fixed occ_skills list. That is not a choice, so
// a mismatch means the class was edited or re-imported since the character was
// built — not the player's fault, and not something that should block a save.
//
// Returns violations (which block a write) and warnings (which do not), so the
// write path and the audit report share one definition of "legal" and cannot
// disagree about it.
//
// TWO THINGS ABOUT SKILL CATEGORIES, both learned from real data:
//
// 1. A character's stored skill rows are not a reliable source of category.
//    The wizard writes `category: "Class"` on every O.C.C. skill, so checking
//    against the stored value reports nonsense. Pass `catalog` — a Map of
//    lowercased skill name to its real category — and it is used in preference.
//
// 2. A character does not record WHICH choice-group a skill was taken to
//    satisfy. A Juicer granted "W.P. Knife" by name is indistinguishable from
//    one who spent a "choose 2 Weapon Proficiencies" pick on it, so counting by
//    category both over- and under-counts. Choice groups are therefore reported
//    as WARNINGS and never block a save.

import { isChoiceGroup, categoryAllows, categoryName } from '../../../../apps/character-creator/js/parser.js';

import { skillGrantsFor } from './leveling.js';

const norm = (s) => String(s ?? '').trim().toLowerCase();

// Build the name → category map the validator wants.
export async function loadSkillCategories(env) {
  const { results } = await env.DB.prepare('SELECT name, category FROM skills').all();
  return new Map(results.map((r) => [norm(r.name), r.category]));
}

// Related-skill allowance grows with level: the class's starting count plus
// every scheduled grant the character has reached. Without this, any character
// who levelled up and spent a pick would read as over their limit.
export function relatedAllowance(cls, level) {
  const base = cls?.skills?.occ_related_skills?.count ?? 0;
  // Only related-kind grants. A class can schedule secondary picks too, and
  // counting those here would let a character hold more related skills than the
  // class ever allowed.
  const granted = skillGrantsFor(cls, 1, level)
    .filter((g) => g.kind !== 'secondary')
    .reduce((n, g) => n + g.count, 0);
  return base + granted;
}

// The same for secondary skills, which can also arrive on a schedule — the Long
// Bowman gets one more at levels 4, 7, 10 and 13. Without this the class's
// starting count was the permanent ceiling, so spending a pick the class had
// just granted failed validation.
export function secondaryAllowance(cls, level) {
  const base = cls?.skills?.secondary_skills?.count ?? 0;
  const granted = skillGrantsFor(cls, 1, level)
    .filter((g) => g.kind === 'secondary')
    .reduce((n, g) => n + g.count, 0);
  return base + granted;
}

export function validateCharacter({ character, cls, skills, attributes, catalog }) {
  // No class definition means no rules to check against. A character whose
  // class was retired must still be saveable — PR 2 made that survivable on
  // purpose, and refusing here would undo it.
  if (!cls) return { skipped: true, violations: [], warnings: [] };

  const violations = [];
  const warnings = [];
  const list = Array.isArray(skills) ? skills : [];
  const level = Number.isFinite(character?.level) ? character.level : 1;

  // The catalog wins over the stored value, which is "Class" on every O.C.C.
  // skill and therefore useless for a category check.
  const categoryOf = (s) => catalog?.get(norm(s.name)) ?? s.category;

  // ─── attribute minimums ───
  // "none" was once encoded as a literal requirement by the importer; an
  // absent, null or "none" value means no requirement.
  const reqs = cls.attribute_requirements;
  if (reqs && typeof reqs === 'object') {
    for (const [attr, min] of Object.entries(reqs)) {
      if (min == null || norm(min) === 'none') continue;
      const needed = parseInt(min, 10);
      if (!Number.isFinite(needed)) continue;
      const have = parseInt(attributes?.[attr], 10);
      if (!Number.isFinite(have)) {
        violations.push({ rule: 'attribute_missing', attribute: attr,
          message: `${attr} is required (minimum ${needed}) but not set` });
      } else if (have < needed) {
        violations.push({ rule: 'attribute_minimum', attribute: attr, needed, have,
          message: `${attr} is ${have}, below the class minimum of ${needed}` });
      }
    }
  }

  // ─── skill counts ───
  const related = list.filter((s) => s.type === 'related');
  const secondary = list.filter((s) => s.type === 'secondary');

  const relatedMax = relatedAllowance(cls, level);
  if (related.length > relatedMax) {
    violations.push({ rule: 'related_count', have: related.length, allowed: relatedMax,
      message: `${related.length} related skills, but this class allows ${relatedMax} at level ${level}` });
  }

  const secondaryMax = secondaryAllowance(cls, level);
  if (secondary.length > secondaryMax) {
    violations.push({ rule: 'secondary_count', have: secondary.length, allowed: secondaryMax,
      message: `${secondary.length} secondary skills, but this class allows ${secondaryMax} at level ${level}` });
  }

  // ─── categories ───
  // Secondary skills are deliberately unrestricted; only related picks are
  // bounded by the class's category list. A skill explicitly marked as an
  // override was allowed by a human and is legal — that is what the flag means.
  const allowed = cls.skills?.occ_related_skills?.categories;
  if (Array.isArray(allowed) && allowed.length) {
    for (const s of related) {
      if (s.override) continue;
      const cat = categoryOf(s);
      // categoryAllows() also enforces the per-category limits the books state
      // — "Espionage: Escape Artist only", "Physical: any except Acrobatics".
      // Shared with the wizard's picker so the two cannot disagree about what
      // is legal.
      if (!categoryAllows(allowed, { name: s.name, category: cat })) {
        const known = allowed.some((c) => norm(categoryName(c)) === norm(cat));
        violations.push({ rule: 'related_category', skill: s.name, category: cat ?? null,
          message: known
            ? `${s.name} is not one this class allows within ${cat}`
            : `${s.name} is ${cat || 'uncategorised'}, which this class does not allow as a related skill` });
      }
    }
  }

  // ─── choice groups (advisory) ───
  // An occ_skills entry with no name is a choice: "pick 2 of these". A
  // character does not record which group a skill was taken for, so a skill the
  // class also grants BY NAME in the same category is indistinguishable from a
  // chosen one. That both over- and under-counts, so this is reported and never
  // enforced — blocking a save on an approximation would be worse than the gap
  // it closes.
  for (const entry of cls.skills?.occ_skills || []) {
    if (!isChoiceGroup(entry)) continue;
    const want = parseInt(entry.choose, 10);
    if (!Number.isFinite(want) || want <= 0) continue;

    const held = list.filter((s) => matchesGroup(s, entry, categoryOf)).length;
    if (held < want) {
      warnings.push({ rule: 'choice_group', choose: want, have: held,
        from: entry.from ?? entry.categories ?? null,
        message: `Looks short of ${want} from ${describeGroup(entry)} (counted ${held}) — approximate` });
    }
  }

  // Duplicates are always wrong, whatever the counts say.
  const seen = new Set();
  for (const s of list) {
    const key = norm(s.name);
    if (!key) continue;
    if (seen.has(key)) {
      violations.push({ rule: 'duplicate_skill', skill: s.name, message: `${s.name} is listed twice` });
    }
    seen.add(key);
  }

  return { skipped: false, violations, warnings };
}

function matchesGroup(skill, entry, categoryOf) {
  if (Array.isArray(entry.from)) {
    return entry.from.some((n) => {
      // "Piloting: any" in a from-list means any skill sharing that prefix.
      const m = String(n).match(/^(.*?):\s*any$/i);
      return m ? norm(skill.name).startsWith(norm(m[1]) + ':') : norm(n) === norm(skill.name);
    });
  }
  if (Array.isArray(entry.categories)) {
    const cat = categoryOf ? categoryOf(skill) : skill.category;
    return entry.categories.some((c) => norm(c) === norm(cat));
  }
  return false;
}

function describeGroup(entry) {
  if (Array.isArray(entry.from)) return entry.from.join(' / ');
  if (Array.isArray(entry.categories)) return entry.categories.join(' / ') + ' skills';
  return 'the listed options';
}
