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

import { isChoiceGroup, categoryAllows, categoryName, needsOccupation,
         isAbilityChoice, isAbilityDefinition, abilityOptions, normalizeAbilities, abilityOccOptions } from '../../../../apps/character-creator/js/parser.js';

import { skillGrantsFor, xpTableFor, thresholdFor } from './leveling.js';
import { isRepeatableRow, otherRowFor } from '../../../../apps/character-creator/js/language-skills.js';

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

export function validateCharacter({ character, cls, skills, attributes, abilities, catalog }) {
  // No class definition means no rules to check against. A character whose
  // class was retired must still be saveable — PR 2 made that survivable on
  // purpose, and refusing here would undo it.
  if (!cls) return { skipped: true, violations: [], warnings: [] };

  const violations = [];
  const warnings = [];

  // A character above level 1 whose XP is behind that level's threshold. Two
  // legitimate sources - a character CREATED at a starting level, and one a
  // G.M. levelled by hand - so this is a warning and never a violation. It
  // exists so the number is visible rather than silently inconsistent with the
  // level beside it.
  if (character?.level > 1 && Number.isFinite(character?.xp)) {
    const needed = thresholdFor(xpTableFor(cls), character.level);
    if (needed != null && character.xp < needed) {
      warnings.push({
        rule: 'xp_below_level', level: character.level, xp: character.xp, needed,
        message: `Level ${character.level} normally needs ${needed} XP; this character has ${character.xp}`,
      });
    }
  }

  // The usual structure is a race and then an occupation. A racial class that
  // grants nothing to CHOOSE - no related, no secondary - is not a playable
  // character on its own: a Demigod alone has no skills at all, and a Chiang-Ku
  // has twenty-four body skills and nothing the player picked.
  //
  // A warning and never a violation. Some races legitimately stand alone, the
  // pairing is a convention rather than a rule the books state as one, and a
  // character part-way through being built must still save.
  //
  // `occ_id` is set by combineClasses, so its absence means no occupation was
  // composed in - and when none was, `cls` IS the racial class, which is what
  // makes the check readable here at all.
  if (!cls.occ_id && needsOccupation(cls)) {
    warnings.push({
      rule: 'no_occupation',
      class_id: cls.id ?? null,
      message: `${cls.name || 'This racial class'} grants no related or secondary skills, `
        + 'so it has nothing for the player to choose - it is normally paired with an O.C.C.',
    });
  }
  // A Military Occupational Specialty. The class offering one says "select one
  // area of specialty, gain all skills under that MOS", so a character with
  // none chosen is missing a package nothing else will mention.
  const mosCfg = cls.skills?.mos;
  if (mosCfg && Array.isArray(mosCfg.options) && mosCfg.options.length) {
    const chosen = character?.mos;
    const match = chosen && mosCfg.options.find(
      (o) => String(o.id || o.name).toLowerCase() === String(chosen).toLowerCase());
    if (!chosen) {
      warnings.push({
        rule: 'mos_unchosen',
        class_id: cls.id ?? null,
        options: mosCfg.options.map((o) => o.name),
        message: `${cls.name || 'This class'} offers a Military Occupational Specialty `
          + 'and none is chosen, so its skill package is missing.',
      });
    } else if (!match) {
      // The class was edited under a saved character. Say which one is gone.
      warnings.push({
        rule: 'mos_unknown',
        class_id: cls.id ?? null,
        mos: String(chosen),
        options: mosCfg.options.map((o) => o.id || o.name),
        message: `"${chosen}" is not a specialty ${cls.name || 'this class'} offers, `
          + 'so none of its skills are being granted.',
      });
    }
  }

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

  // ── chosen abilities ──────────────────────────────────────────────────────
  // The wizard enforces the count, the offered list and repeatability at pick
  // time; until now nothing re-checked them, so a direct API call could save a
  // Godling with five powers. Same posture as the skill rules: what a player
  // CHOSE gets a boundary, and anything a class edit could have caused warns
  // instead of blocking.
  //
  // A `{ name, gm: true }` entry is a ruling, not a pick — the Demigod's "most
  // have ONE extra power, similar to the godly parent's" is assigned by hand —
  // so it is exempt from the count and never checked against the offered list,
  // the same reasoning that makes an `override: true` skill legal by definition.
  {
    const groups = (cls.special_abilities || []).filter(isAbilityChoice);
    const allowed = groups.reduce((n, g) => n + (+g.choose || 0), 0);
    const offered = new Set(abilityOptions(cls).map(norm));
    const defs = new Map((cls.special_abilities || [])
      .filter(isAbilityDefinition).map((d) => [norm(d.name), d]));
    const picks = normalizeAbilities(abilities);

    const player = picks.filter((p) => !p.gm);
    if (player.length > allowed) {
      violations.push({ rule: 'ability_count', have: player.length, allowed,
        message: `${player.length} chosen power${player.length === 1 ? '' : 's'}, `
          + `but this class allows ${allowed}` });
    }
    for (const p of player) {
      if (!offered.has(norm(p.name))) {
        warnings.push({ rule: 'ability_unknown', name: p.name,
          message: `${p.name} is not a power this class offers — the class may have `
            + 'been edited since this character was built' });
      }
    }
    // Repeats count player and G.M. copies together: holding a power twice is
    // holding it twice, whoever granted the second.
    const times = new Map();
    for (const p of picks) times.set(norm(p.name), (times.get(norm(p.name)) || 0) + 1);
    for (const [key, n] of times) {
      if (n < 2) continue;
      const def = defs.get(key);
      const label = def?.name || picks.find((p) => norm(p.name) === key).name;
      if (def && def.repeatable !== true) {
        violations.push({ rule: 'ability_repeat', name: label, times: n,
          message: `${label} is taken ${n} times, but cannot be taken more than once` });
      } else if (n > 2) {
        warnings.push({ rule: 'ability_repeat', name: label, times: n,
          message: `${label} is taken ${n} times — the book says twice` });
      }
    }

    // An ability that names occupations (occ_options - the Godling's Magic
    // Powers) is satisfied by one of them being the character's occupation.
    // A warning and never a violation: a class edit is not the player's
    // fault, and an old character must keep saving.
    const occNeed = abilityOccOptions(cls, picks.map((p) => p.name));
    if (occNeed && (!character?.occ_class_id || !occNeed.options.includes(character.occ_class_id))) {
      warnings.push({ rule: 'ability_occ', name: occNeed.name,
        message: `${occNeed.name} expects one of these occupations composed in: `
          + occNeed.options.join(', ')
          + (character?.occ_class_id ? ` - this character has ${character.occ_class_id}` : ' - this character has none') });
    }
  }

  return { skipped: false, violations, warnings };
}

function matchesGroup(skill, entry, categoryOf) {
  if (Array.isArray(entry.from)) {
    return entry.from.some((n) => {
      // "Piloting: any" in a from-list means any skill sharing that prefix.
      const m = String(n).match(/^(.*?):\s*any$/i);
      if (m) return norm(skill.name).startsWith(norm(m[1]) + ':');
      // A group offering a family's Other row is satisfied by any member of
      // THAT family, because the pick is STORED under its own name - Language:
      // Elven, not Language: Other. Without this a Knight who took the two
      // languages his book grants reads as having taken none, and the save
      // carries a "looks short of 2" warning for doing exactly the right thing.
      // Family-matched rather than merely name-matched, so a Literacy pick is
      // not satisfied by a spoken language.
      if (isRepeatableRow(n)) return norm(otherRowFor(skill.name) ?? '') === norm(n);
      return norm(n) === norm(skill.name);
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
