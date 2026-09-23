// The name generator: shared/js/namegen.js and its word lists.
//
// Phase 4 of the NPC / bestiary work. The module is pure, so everything that
// does not need a request is proved here: every theme can fill a list in every
// form it offers, the engine refuses rather than pads, an excluded name never
// comes back, and the lists are as big as the plan said they must be. The
// endpoints - the G.M. guard, the campaign's own names read from D1, the
// roller's 422 before any write - are regression.mjs's, because only a request
// can prove them.
//
// SEEN TO FAIL, 2026-09-23, with the fault injected upstream of the check:
//   - a four-name theme added to THEMES turned the sweep red (it cannot fill a
//     list of 12 in any form) - on its own. Injected together with the next
//     fault the sweep stayed GREEN, because padding filled the tiny theme's
//     lists to 12; the distinctness check caught it instead. Each fault hides
//     the other's first symptom, so inject them one at a time;
//   - generateNames made to top a short list up with repeats turned the
//     refusal and distinctness checks red;
//   - the exclude filter removed turned both exclusion checks red.

import { check, section, wantSection } from '../harness.mjs';
import { THEMES, KINDS, GENDERS, MAX_COUNT, CLASS_THEMES, SYSTEM_THEMES, PLACE_THEMES, generateNames,
  spaceSize, partCount, nameKey, defaultThemeFor, themeSummaries, NameGenError }
  from '../../../../shared/js/namegen.js';

const SECTIONS = ['Name generator'];

// A repeatable random, so a failure names the same list every run.
function seeded(seed) {
  let s = seed >>> 0;
  return () => {
    s = (s + 0x6d2b79f5) >>> 0;
    let t = s;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

export function run() {
  if (!SECTIONS.some(wantSection)) return;
  section('Name generator');

  // ── every theme, every form it offers, fills a list ──
  // The point of a theme is that a G.M. asking for twelve gets twelve. A
  // built-in theme too small to do that in some form it OFFERS is a content
  // bug, so the sweep asks for the maximum and wants it without exhaustion.
  const short = [];
  const bad = [];
  let cases = 0;
  for (const t of THEMES) {
    for (const kind of Object.keys(t.kinds)) {
      const forms = kind === 'person'
        ? Object.keys(t.kinds.person.shapes).flatMap((shape) => GENDERS.map((gender) => ({ shape, gender })))
        : [{ shape: null, gender: 'any' }];
      for (const f of forms) {
        cases++;
        const r = generateNames({ theme: t.id, kind, ...f, count: MAX_COUNT, random: seeded(cases) });
        const label = `${t.id} ${kind}${f.shape ? ' ' + f.shape + '/' + f.gender : ''}`;
        if (r.exhausted || r.names.length !== MAX_COUNT) short.push(`${label}: ${r.reason}`);
        if (new Set(r.names.map(nameKey)).size !== r.names.length
            || r.names.some((n) => !n.trim() || /[{}]/.test(n))) bad.push(`${label}: ${r.names.join(' / ')}`);
      }
    }
  }
  check(`every theme fills a list of ${MAX_COUNT} in every kind, shape and gender it offers (${cases} forms)`,
    short.length === 0, short.slice(0, 6).join('; '));
  check('and every name in them is distinct, non-empty and has no unfilled {slot}',
    bad.length === 0, bad.slice(0, 3).join('; '));

  // ── refuse, never pad ──
  const tiny = { id: 'fixture-tiny', label: 'Tiny fixture', games: ['generic'], cultures: [],
    kinds: { person: { lists: { given: { masc: ['Abel', 'Brom'], fem: ['Cora'], neutral: [] } },
      shapes: { given: ['{given}'] }, defaultShape: 'given' } } };
  const r2 = generateNames({ theme: tiny, gender: 'masc', count: 5, random: seeded(1) });
  check('a theme that runs out returns fewer names, never a repeat, and says why',
    r2.names.length === 2 && new Set(r2.names).size === 2 && r2.exhausted === true
      && /2 distinct/.test(r2.reason || ''), JSON.stringify(r2));
  const rNone = generateNames({ theme: tiny, gender: 'neutral', count: 3 });
  check('a form with no names at all is refused by name, not filled from another gender',
    rNone.names.length === 0 && rNone.exhausted === true && !!rNone.reason, JSON.stringify(rNone));
  const rAny = generateNames({ theme: tiny, gender: 'any', count: 12 });
  check('"any" gender is the genders together, still with nothing borrowed from outside the theme',
    rAny.names.length === 3 && rAny.names.every((n) => ['Abel', 'Brom', 'Cora'].includes(n)), JSON.stringify(rAny));

  // ── exclude ──
  const rEx = generateNames({ theme: tiny, gender: 'masc', count: 5, exclude: ['  abel '] });
  check('an excluded name never comes back, whatever its case and spacing',
    rEx.names.length === 1 && rEx.names[0] === 'Brom' && /1 of them is already in use/.test(rEx.reason || ''),
    JSON.stringify(rEx));
  const bigEx = generateNames({ theme: 'pf-eastern-territory', count: 12, random: seeded(7) });
  const again = generateNames({ theme: 'pf-eastern-territory', count: 12, random: seeded(7), exclude: bigEx.names });
  check('and holds on a sampled theme too, not only an enumerated one',
    again.names.length === 12 && !again.names.some((n) => bigEx.names.map(nameKey).includes(nameKey(n))));

  // ── a seed repeats; "any" keeps a name to one gender ──
  const a = generateNames({ theme: 'rifts-sovietski', count: 8, random: seeded(42) });
  const b = generateNames({ theme: 'rifts-sovietski', count: 8, random: seeded(42) });
  check('the same seed gives the same list', JSON.stringify(a.names) === JSON.stringify(b.names));
  const sov = THEMES.find((t) => t.id === 'rifts-sovietski').kinds.person.lists;
  const mixed = generateNames({ theme: 'rifts-sovietski', gender: 'any', shape: 'given+family', count: 12,
    random: seeded(3) }).names.filter((n) => {
    const [given, family] = n.split(' ');
    return (sov.given.fem.includes(given) && sov.family.masc.includes(family))
      || (sov.given.masc.includes(given) && sov.family.fem.includes(family));
  });
  check('"any" gender never pairs a feminine given name with a masculine family name, or back',
    mixed.length === 0, mixed.join(', '));

  // ── requests it cannot serve are errors, not empty lists ──
  const throws = (fn) => { try { fn(); return false; } catch (e) { return e instanceof NameGenError; } };
  check('an unknown theme, a kind a theme does not make, and a shape it does not have are refused',
    throws(() => generateNames({ theme: 'nope' }))
      && throws(() => generateNames({ theme: 'rifts-frontier', kind: 'ship' }))
      && throws(() => generateNames({ theme: 'nb-modern', shape: 'callsign' })));

  // ── the size the plan asked for ──
  // The City Creator plan: 200 or more name parts per culture and a table big
  // enough that two cities do not share names. Palladium Fantasy is the game
  // its first phase builds; Rifts came with its fifth, when the Dog Boy (146)
  // and Atlantean (162) themes were short of the bar and were filled out.
  const thin = THEMES.filter((t) => t.kinds.person && t.games.some((g) => g === 'palladium-fantasy' || g === 'rifts')
    && partCount(t) < 200).map((t) => `${t.id} ${partCount(t)}`);
  check('every Palladium Fantasy and Rifts people theme has 200 or more name parts', thin.length === 0, thin.join(', '));
  const smallPlaces = THEMES.flatMap((t) => Object.keys(t.kinds).filter((k) => k !== 'person')
    .map((k) => [`${t.id} ${k}`, spaceSize({ theme: t, kind: k })])).filter(([, n]) => n < 500);
  check('every place and group kind can make 500 or more names', smallPlaces.length === 0,
    smallPlaces.map((x) => x.join(' ')).join(', '));
  const everyGame = ['rifts', 'palladium-fantasy', 'nightbane'];
  check('each game has a places theme that names all five kinds of place and group',
    everyGame.every((g) => {
      const t = THEMES.find((x) => x.id === PLACE_THEMES[g]);
      return t && ['tavern', 'shop', 'district', 'gang'].every((k) => t.kinds[k])
        && (g === 'nightbane' || t.kinds.ship);
    }));

  // ── the defaults point at themes that exist ──
  const people = new Set(THEMES.filter((t) => t.kinds.person).map((t) => t.id));
  const brokenDefaults = [...Object.entries(CLASS_THEMES), ...Object.entries(SYSTEM_THEMES)]
    .filter(([, id]) => !people.has(id)).map(([k, id]) => `${k} -> ${id}`);
  check('every class and game default names a people theme that exists', brokenDefaults.length === 0,
    brokenDefaults.join(', '));
  check('the class wins over the game, and an occupation over a race',
    defaultThemeFor({ classId: 'wolfen', system: 'palladium-fantasy' }) === 'pf-wolfen'
      && defaultThemeFor({ classId: 'human', system: 'palladium-fantasy' }) === 'pf-eastern-territory'
      && defaultThemeFor({ classId: 'wolfen', occClassId: 'noble', system: 'palladium-fantasy' }) === 'pf-western-empire');
  check('a game\'s theme list carries its own themes and the generic ones only',
    themeSummaries('palladium-fantasy').every((t) => t.games.includes('palladium-fantasy') || t.games.includes('generic'))
      && themeSummaries('heroes-unlimited').some((t) => t.id === 'nb-modern'));
  check('every theme names a kind the engine knows',
    THEMES.every((t) => Object.keys(t.kinds).every((k) => KINDS.includes(k))));
}
