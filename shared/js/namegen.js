// Names for people, places and groups - the engine. The word lists are
// shared/js/namegen-themes.js; this file only knows how to spend them.
//
// Phase 4 of the NPC / bestiary work (Nate, 2026-09-22). A G.M. needs "a name,
// now" for the barkeep, the ship and the gang, and until this every NPC was
// "Brodkil 1, Brodkil 2". The decisions this follows, none of them open:
//   - curated word lists plus syllable rules, in plain JS - no Markov model and
//     no AI call, so a list is instant, free and the same on every machine;
//   - the themes live in code, not in D1, so there is no schema to move;
//   - every theme carries a GAME tag and CULTURE tags, and a picker filters by
//     either;
//   - nothing is saved - a list is a suggestion, and the page holds the pins.
//
// A PURE module with an injectable `random`, like js/npc-generate.js, so a test
// can repeat a run and the City Creator can seed one. The campaign endpoints
// run it on the server, where they can exclude the names a campaign already
// uses; the City Creator runs it in the browser with its own seeded random.
//
// ── Refuse, never pad ──
// Nate's rule for every generator here: a theme that runs out of distinct names
// returns FEWER and says why. It never repeats a name, never borrows another
// theme's list, and never invents a filler ("Guard 7"). A short list with a
// reason is a finished answer; a padded one is a wrong one that looks right.
//
// ── How a list is made ──
// A kind (person, tavern, ship...) is a set of PATTERNS such as
// "{given} {family}" or "The {adj} {noun}". A slot is a word list, a gendered
// set of lists, or a JOIN of syllable lists glued into one word - the syllable
// rule. The names a pattern can make are the product of its slots, so the size
// of the whole space is known before anything is drawn. A space small enough
// to write out is written out, filtered and shuffled, which makes "exhausted"
// exact rather than a guess about unlucky draws. A larger one is sampled, and
// sampling stops at a fixed number of tries per name.

import { THEMES as BUILT_IN, CLASS_THEMES, SYSTEM_THEMES, PLACE_THEMES } from './namegen-themes.js';

export const KINDS = ['person', 'tavern', 'shop', 'ship', 'district', 'gang'];
export const KIND_LABELS = {
  person: 'person', tavern: 'tavern or inn', shop: 'shop or business', ship: 'ship',
  district: 'district', gang: 'gang, guild or cult',
};
export const GENDERS = ['any', 'masc', 'fem', 'neutral'];
export const SHAPES = ['given', 'given+family', 'epithet', 'callsign'];
export const SHAPE_LABELS = {
  given: 'given name', 'given+family': 'given + family', epithet: '+ epithet', callsign: 'callsign',
};
export const MAX_COUNT = 12;

// Below this many possible names a space is written out in full. Measured
// cheap: 60,000 short strings is a few milliseconds.
const ENUMERATE_LIMIT = 60000;
// Draws allowed per name wanted when a space is too big to write out.
const SAMPLE_TRIES = 400;

// A request the module cannot serve at all - an unknown theme, a kind or shape
// the theme does not have. Different from running out: that is a result.
export class NameGenError extends Error {
  constructor(message) { super(message); this.name = 'NameGenError'; }
}

// The key two names are the same under: case, and runs of spaces.
export const nameKey = (s) => String(s).trim().replace(/\s+/g, ' ').toLowerCase();

function findTheme(id, themes = BUILT_IN) {
  return themes.find((t) => t.id === id) || null;
}

// What the picker shows: every theme a game can use (its own and the generic
// ones), without the word lists.
export function themeSummaries(system = null, themes = BUILT_IN) {
  return themes
    .filter((t) => !system || t.games.includes(system) || t.games.includes('generic'))
    .map((t) => ({
      id: t.id, label: t.label, games: [...t.games], cultures: [...t.cultures],
      kinds: Object.keys(t.kinds),
      shapes: t.kinds.person ? Object.keys(t.kinds.person.shapes) : [],
      default_shape: t.kinds.person?.defaultShape ?? null,
      blurb: t.blurb || '',
    }));
}

// The theme a class or race starts on: the class's own if it has one (a Wolfen
// gets Wolfen names, a Coalition grunt a rank and callsign), then its race's,
// then the game's.
export function defaultThemeFor({ classId = null, occClassId = null, system = null } = {}) {
  return CLASS_THEMES[occClassId] || CLASS_THEMES[classId] || SYSTEM_THEMES[system] || null;
}
export { CLASS_THEMES, SYSTEM_THEMES, PLACE_THEMES };

// ── the space ──

// A slot's word list for this request, as an array of candidate strings or a
// syllable join still to expand.
// A gendered slot is { masc, fem, neutral }. "any" never reaches here: it is
// compiled once per gender (patternsFor), so one name is never half masculine
// and half feminine - a Slavic family name agrees with its given name.
function slotSource(kindDef, slot, gender) {
  const src = kindDef.lists[slot];
  if (src == null) throw new NameGenError(`pattern slot {${slot}} has no list`);
  if (Array.isArray(src) || src.join) return src;
  return src[gender] || [];
}

// Every string a source can produce. Syllable joins glue their parts and tidy
// the seam.
function expand(src) {
  if (Array.isArray(src)) return src;
  if (src.join) {
    let out = [''];
    for (const part of src.join) {
      const next = [];
      for (const head of out) for (const tail of part) next.push(head + tail);
      out = next;
    }
    return out.map(tidy);
  }
  return [];
}

function sourceSize(src) {
  if (Array.isArray(src)) return src.length;
  if (src.join) return src.join.reduce((n, part) => n * part.length, 1);
  return 0;
}

function drawFrom(src, random) {
  if (Array.isArray(src)) return src[Math.floor(random() * src.length)];
  if (src.join) return tidy(src.join.map((part) => part[Math.floor(random() * part.length)]).join(''));
  return '';
}

// The syllable rule's seam: no letter three times running, and a capital
// first letter, so "Gra" + "aak" is "Graak" and "ul" + "..." still reads as a name.
export function tidy(word) {
  const w = String(word).replace(/([a-z])\1\1+/gi, '$1$1');
  return w.charAt(0).toUpperCase() + w.slice(1);
}

const TOKEN = /\{([a-z_]+)\}/g;

function compile(pattern, kindDef, gender) {
  const pieces = [];
  let last = 0;
  for (const m of pattern.matchAll(TOKEN)) {
    if (m.index > last) pieces.push([pattern.slice(last, m.index)]);
    pieces.push(slotSource(kindDef, m[1], gender));
    last = m.index + m[0].length;
  }
  if (last < pattern.length) pieces.push([pattern.slice(last)]);
  return pieces;
}

// The patterns a request draws from, compiled.
function patternsFor(theme, kind, gender, shape) {
  const kindDef = theme.kinds[kind];
  if (!kindDef) {
    throw new NameGenError(`${theme.label} has no ${KIND_LABELS[kind] || kind} names`);
  }
  let patterns;
  if (kind === 'person') {
    const s = shape || kindDef.defaultShape;
    patterns = kindDef.shapes[s];
    if (!patterns) {
      throw new NameGenError(`${theme.label} names have no ${SHAPE_LABELS[s] || s} form - it has `
        + Object.keys(kindDef.shapes).map((k) => SHAPE_LABELS[k] || k).join(', '));
    }
  } else {
    patterns = kindDef.patterns;
  }
  const genders = kind === 'person' && gender === 'any' ? ['masc', 'fem', 'neutral'] : [gender];
  return genders.flatMap((g) => patterns.map((p) => compile(p, kindDef, g)));
}

const piecesSize = (pieces) => pieces.reduce((n, src) => n * sourceSize(src), 1);

function enumerate(pieces) {
  let out = [''];
  for (const src of pieces) {
    const words = expand(src);
    const next = [];
    for (const head of out) for (const w of words) next.push(head + w);
    out = next;
  }
  return out;
}

// ── generating ──

/**
 * Up to `count` distinct names from one theme.
 *
 * theme    a theme id, or a theme object (a test injects one this way)
 * kind     person | tavern | shop | ship | district | gang
 * gender   any | masc | fem | neutral - people only
 * shape    given | given+family | epithet | callsign - people only, and only
 *          the shapes the theme has; omitted, the theme's default
 * count    1-12
 * exclude  names that must not come back: the campaign's own, and the chips
 *          already on screen. Compared case-insensitively.
 * random   injectable, so a test can repeat a run
 *
 * Returns { names, exhausted, reason }. `exhausted` is true when fewer than
 * `count` came back, and `reason` then says how many the theme has in all and
 * how many were ruled out - never a filler name.
 */
export function generateNames({ theme, kind = 'person', gender = 'any', shape = null, count = 6,
  exclude = [], random = Math.random, themes = BUILT_IN } = {}) {
  const t = typeof theme === 'string' ? findTheme(theme, themes) : theme;
  if (!t) throw new NameGenError(`No name theme called ${theme}`);
  if (!KINDS.includes(kind)) throw new NameGenError(`Not a kind of name: ${kind}`);
  if (!GENDERS.includes(gender)) throw new NameGenError(`Not a gender option: ${gender}`);
  const want = Math.max(1, Math.min(MAX_COUNT, Math.trunc(Number(count)) || 1));
  const banned = new Set((exclude || []).map(nameKey));
  const compiled = patternsFor(t, kind, kind === 'person' ? gender : 'any', shape);
  const size = compiled.reduce((n, p) => n + piecesSize(p), 0);

  const what = kind === 'person' ? 'names' : `${KIND_LABELS[kind]} names`;
  if (size === 0) {
    return { names: [], exhausted: true,
      reason: `${t.label} has no ${gender === 'any' ? '' : gender + ' '}${what} of that form` };
  }

  const picked = [];
  const seen = new Set();
  if (size <= ENUMERATE_LIMIT) {
    const all = [];
    for (const p of compiled) {
      for (const n of enumerate(p)) {
        const k = nameKey(n);
        if (seen.has(k)) continue;
        seen.add(k);
        all.push(n);
      }
    }
    const free = all.filter((n) => !banned.has(nameKey(n)));
    // Fisher-Yates over the free names, stopping once there are enough.
    for (let i = 0; i < free.length && picked.length < want; i++) {
      const j = i + Math.floor(random() * (free.length - i));
      [free[i], free[j]] = [free[j], free[i]];
      picked.push(free[i]);
    }
    if (picked.length < want) {
      const used = all.length - free.length;
      return { names: picked, exhausted: true,
        reason: `${t.label} has ${all.length} distinct ${all.length === 1 ? what.replace(/s$/, '') : what} of this form`
          + (used ? `, and ${used} of them ${used === 1 ? 'is' : 'are'} already in use or on screen` : '')
          + ` - ${picked.length ? `only ${picked.length} left` : 'none left'}` };
    }
    return { names: picked, exhausted: false, reason: null };
  }

  // Too many to write out: draw a pattern by its share of the space, then a
  // word per slot.
  const weights = compiled.map(piecesSize);
  for (let tries = 0; picked.length < want && tries < want * SAMPLE_TRIES; tries++) {
    let at = Math.floor(random() * size);
    let p = 0;
    while (at >= weights[p]) { at -= weights[p]; p++; }
    const n = compiled[p].map((src) => drawFrom(src, random)).join('');
    const k = nameKey(n);
    if (seen.has(k) || banned.has(k)) continue;
    seen.add(k);
    picked.push(n);
  }
  if (picked.length < want) {
    return { names: picked, exhausted: true,
      reason: `${t.label} ran out of unused ${what} after ${want * SAMPLE_TRIES} tries` };
  }
  return { names: picked, exhausted: false, reason: null };
}

// How many distinct names a theme can make for one request - the smoke check's
// measure of whether a list is big enough to feel different twice.
export function spaceSize({ theme, kind = 'person', gender = 'any', shape = null, themes = BUILT_IN }) {
  const t = typeof theme === 'string' ? findTheme(theme, themes) : theme;
  const compiled = patternsFor(t, kind, kind === 'person' ? gender : 'any', shape);
  return compiled.reduce((n, p) => n + piecesSize(p), 0);
}

// The distinct words a theme is built from - the "name parts" the City Creator
// plan counts (200 or more per culture).
export function partCount(theme) {
  const words = new Set();
  const walk = (src) => {
    if (Array.isArray(src)) src.forEach((w) => words.add(nameKey(w)));
    else if (src?.join) src.join.forEach(walk);
    else if (src && typeof src === 'object') Object.values(src).forEach(walk);
  };
  for (const k of Object.values(theme.kinds)) walk(k.lists);
  return words.size;
}

export const THEMES = BUILT_IN;
