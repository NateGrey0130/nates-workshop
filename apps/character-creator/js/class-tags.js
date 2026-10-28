// Class tags: the vocabulary, the derived and suggested tags, and the
// validator's half. Moved out of js/parser.js verbatim; parser.js re-exports
// every name it exported before.
//
// The import below is a cycle (parser.js imports this file). Safe for the
// reason js/abilities.js gives: nothing at either file's top level reads the
// other's bindings.
import { skillOptionName } from './parser.js';

// ── class tags ──
// Labels that help a player choose a class: the Race and Occupation steps
// filter on them, and the guided quiz scores against them. They are a picking
// aid and nothing else; no rule reads one.
//
// TWO KINDS, and the split is the point. A DERIVED tag restates a block the
// class already has (`magic:` means it casts), so it is computed, and writing
// it beside the block is refused: a hand-written `magic` would go on claiming
// magic after the block was removed. It MAY be written on a class that has no
// such block, because some books grant the thing without one - Heroes
// Unlimited's Magic power category works its magic through special abilities
// and would otherwise never reach the Magic chip. The validator warns so the
// writer checks the book says so. An AUTHORED tag is a judgement no field records - "plays
// quietly", "good first character" - and lives in the class's own frontmatter
// as `tags: [stealth, wilderness]`, at most MAX_AUTHORED_TAGS of them.
//
// Order is display order: derived first, then role, nature and guidance.
export const CLASS_TAGS = [
  { id: 'magic', label: 'Magic', kind: 'derived', hint: 'Casts spells or works magic' },
  { id: 'psionics', label: 'Psionics', kind: 'derived', hint: 'Has psychic powers' },
  { id: 'mega-damage', label: 'Mega-Damage', kind: 'derived', hint: 'A natural M.D.C. being' },
  { id: 'horror-factor', label: 'Frightening', kind: 'derived', hint: 'Projects a Horror Factor' },
  { id: 'combat', label: 'Combat', kind: 'authored', group: 'role', hint: 'A front-line fighter' },
  { id: 'ranged', label: 'Ranged', kind: 'authored', group: 'role', hint: 'Fights at range: marksman, archer, gunslinger' },
  { id: 'stealth', label: 'Stealth', kind: 'authored', group: 'role', hint: 'Thief, spy or assassin' },
  { id: 'scholar', label: 'Scholar', kind: 'authored', group: 'role', hint: 'Knowledge, lore or science' },
  { id: 'tech', label: 'Tech', kind: 'authored', group: 'role', hint: 'Operator, hacker or cyber-doc' },
  { id: 'pilot', label: 'Pilot', kind: 'authored', group: 'role', hint: 'Vehicles, robots or power armor' },
  { id: 'healer', label: 'Healer', kind: 'authored', group: 'role', hint: 'Medical or magical healing' },
  { id: 'wilderness', label: 'Wilderness', kind: 'authored', group: 'role', hint: 'Ranger, scout or survivalist' },
  { id: 'leader', label: 'Leader', kind: 'authored', group: 'role', hint: 'Face, diplomat or noble' },
  { id: 'hunter', label: 'Hunter', kind: 'authored', group: 'role', hint: 'Hunts monsters, vampires or demons' },
  { id: 'augmented', label: 'Augmented', kind: 'authored', group: 'nature', hint: 'Bionics, cybernetics or chemical augmentation' },
  { id: 'supernatural', label: 'Supernatural', kind: 'authored', group: 'nature', hint: 'A dragon, demon or creature of magic' },
  { id: 'shapeshifter', label: 'Shapeshifter', kind: 'authored', group: 'nature', hint: 'Changes shape' },
  { id: 'flyer', label: 'Flyer', kind: 'authored', group: 'nature', hint: 'Flies without equipment' },
  { id: 'aquatic', label: 'Aquatic', kind: 'authored', group: 'nature', hint: 'At home underwater' },
  { id: 'divine', label: 'Divine', kind: 'authored', group: 'nature', hint: 'Priest, cleric or servant of a god' },
  { id: 'beginner', label: 'Beginner', kind: 'authored', group: 'guidance', hint: 'Few choices; plays simply' },
  { id: 'high-power', label: 'High power', kind: 'authored', group: 'guidance', hint: 'Usually needs the GM\'s approval' },
  // The book restricts the class to evil alignments, OR to anarchist-or-evil, OR
  // every alignment it lists is evil. Not when a good or unprincipled one is
  // allowed ("selfish or evil" does not qualify). Nate's ruling, set on the
  // Palladium Fantasy Assassin; the label said "Evil only" until it covered
  // anarchist too.
  { id: 'evil', label: 'Evil', kind: 'authored', group: 'guidance', hint: 'Restricted to evil, or to anarchist or evil, alignments' },
];
export const MAX_AUTHORED_TAGS = 4;
const TAG_BY_ID = new Map(CLASS_TAGS.map((t) => [t.id, t]));

export function classTagInfo(id) {
  return TAG_BY_ID.get(id) || null;
}

// The four derived tags, from the blocks they restate. Kept beside the
// vocabulary so a new derived tag cannot be declared without its rule.
//
// The class OR ANY OF ITS VARIANTS: a block a variant carries is one the class
// can have. The Palladium Fantasy dragons state horror_factor per age stage
// and none at the top, and the Mining Borg its M.D.C. per conversion; read
// from the top alone, none of them reached the chip.
function derivedTags(c) {
  const forms = [c, ...(Array.isArray(c?.variants) ? c.variants : [])].filter(Boolean);
  const any = (test) => forms.some(test);
  const out = [];
  if (any((f) => f.magic && f.magic.type !== 'none')) out.push('magic');
  if (any((f) => f.psionics && f.psionics.type && f.psionics.type !== 'none')) out.push('psionics');
  if (any((f) => f.mdc_base != null || f.mdc_from_hp_sdc)) out.push('mega-damage');
  if (any((f) => f.horror_factor != null)) out.push('horror-factor');
  return out;
}

/**
 * Every tag a class carries - derived, then written - in vocabulary order.
 * A written id the vocabulary does not hold is dropped rather than shown: the
 * validator refuses one, so this only matters for a row that skipped it. A
 * written derived id counts, which is how a class with no block for it gets
 * the tag (see CLASS_TAGS).
 */
export function classTags(c) {
  const have = new Set(derivedTags(c));
  for (const t of Array.isArray(c?.tags) ? c.tags : []) {
    if (TAG_BY_ID.has(t)) have.add(t);
  }
  return CLASS_TAGS.filter((t) => have.has(t.id)).map((t) => t.id);
}

/**
 * Authored tags a class probably deserves, guessed from what it already says:
 * its occ_group, its skill names, its name, its natural abilities and its
 * restrictions. A STARTING POINT FOR A PERSON, never a value that ships
 * unread - scripts/class-tags.mjs prints these for review, and class-check
 * offers them on a class with no tags line. `beginner` is never
 * guessed: it is exactly the judgement no field records.
 */
export function suggestClassTags(c) {
  if (!c) return [];
  const name = String(c.name || '').toLowerCase();
  const skills = [
    ...(c.skills?.occ_skills || []).map((s) => s?.name || (s?.from || []).map(skillOptionName).join(' ')),
  ].map((s) => String(s || '').toLowerCase());
  const hasSkill = (re) => skills.some((s) => re.test(s));
  const countSkills = (re) => skills.filter((s) => re.test(s)).length;
  const text = (v) => (v == null ? '' : JSON.stringify(v).toLowerCase());
  const natural = text(c.natural_abilities) + text(c.special_abilities);
  const rules = text(c.restrictions) + text(c.alignment) + text(c.side_effects);
  const out = new Set();

  if (c.occ_group === 'men-of-arms'
    || /warrior|soldier|knight|mercenary|gladiator|fighter|juicer|crazy|grunt|samurai|headhunter|borg|berserker|champion|commando/.test(name)) out.add('combat');
  if (hasSkill(/sharpshoot|sniper/) || /gunslinger|gunfighter|sniper|archer|bowman|marksman/.test(name)) out.add('ranged');
  if ((hasSkill(/^prowl/) && hasSkill(/palming|pick locks|concealment|pick pockets/))
    || /thief|spy|assassin|ninja|rogue|smuggler|burglar|infiltrat/.test(name)) out.add('stealth');
  if (countSkills(/^lore|^science|^mathematics|^research|^anthropolog|^archaeolog|^history/) >= 3
    || /scholar|scientist|sage|professor|scribe/.test(name)) out.add('scholar');
  if (countSkills(/computer|electronic|mechanical engineer|robot mechanics|weapons engineer|field armorer/) >= 2
    || /operator|hacker|techno|engineer|cyber-doc|mechanic/.test(name)) out.add('tech');
  if (hasSkill(/pilot: (robot|power armor|jet|helicopter|tank)|robot combat/)
    || /pilot|glitter boy|sam\b|rpa/.test(name)) out.add('pilot');
  if (hasSkill(/medical doctor|paramedic|holistic medicine|cybernetic medicine/)
    || /healer|doctor|medic\b|cyber-doc|body fixer/.test(name)) out.add('healer');
  if (countSkills(/wilderness survival|track|land navigation|hunting|identify plants|skin & prepare/) >= 3
    || /ranger|scout|trapper|wilderness|woodsman|nomad|tracker/.test(name)) out.add('wilderness');
  if (/noble|diplomat|lord|king|queen|chieftain|captain|commander|emissary/.test(name)) out.add('leader');
  if (/hunter|slayer|monster|demon quest|vampire/.test(name) && c.category === 'occ') out.add('hunter');
  if (/juicer|crazy|cyborg|borg\b|bionic|m\.o\.m|headhunter|cyber-knight/.test(name)) out.add('augmented');
  if (c.category === 'rcc' && (c.horror_factor != null
    || /dragon|demon|deevil|vampire|spirit|entity|godling|demigod|elemental/.test(name))) out.add('supernatural');
  if (/shape-?chang|metamorph|shapeshift|change (its|their) (shape|form)/.test(natural + text(c.lore))
    || /changeling/.test(name)) out.add('shapeshifter');
  if (/\bfl(y|ies|ight|ying)\b|wings/.test(natural)) out.add('flyer');
  if (/underwater|aquatic|gills|amphibi|breathe water/.test(natural + name)) out.add('aquatic');
  if (c.occ_group === 'clergy' || /priest|shaman|cleric|monk|druid|paladin/.test(name)) out.add('divine');
  if (/dragon|godling|demigod|cosmo-knight|god\b/.test(name)) out.add('high-power');
  if (/(only|must be)( be)? (of )?(an )?evil|evil alignments? only|miscreant or diabolic|diabolic or miscreant/.test(rules)) out.add('evil');

  return CLASS_TAGS.filter((t) => out.has(t.id)).map((t) => t.id);
}

// The validator's half: refuses what the picker would otherwise quietly drop.
export function validateTags(tags, errors, warnings, data) {
  const derived = derivedTags(data);
  if (!Array.isArray(tags)) {
    errors.push('tags must be a one-line list, e.g. tags: [stealth, wilderness]');
    return;
  }
  const seen = new Set();
  for (const t of tags) {
    const info = TAG_BY_ID.get(t);
    if (!info) {
      errors.push(`tags names "${t}", which is not a class tag. Known: `
        + CLASS_TAGS.filter((x) => x.kind === 'authored').map((x) => x.id).join(', '));
    } else if (info.kind === 'derived' && derived.includes(t)) {
      errors.push(`tags names "${t}", which this class's own blocks already derive; `
        + 'remove it, or it outlives the block');
    } else if (info.kind === 'derived') {
      warnings.push(`tags names "${t}" on a class with no block that derives it. Keep it `
        + 'only if the book grants it some other way (Heroes Unlimited Magic works through '
        + 'special abilities)');
    }
    if (seen.has(t)) warnings.push(`tags names "${t}" twice`);
    seen.add(t);
  }
  if (tags.length > MAX_AUTHORED_TAGS) {
    warnings.push(`tags names ${tags.length}; keep it to ${MAX_AUTHORED_TAGS} or fewer, `
      + 'or the filter stops telling classes apart');
  }
}
