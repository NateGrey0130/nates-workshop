// The Marvel codex's rules: every Power, Talent, Contact, Weakness and piece of
// gear the app ships, and the sourcebooks' Notable NPCs, as one list per
// section. Pure, so the smoke suite runs it; codex/app.js is the only code that
// draws it.
//
// ONE DESCRIPTOR PER SECTION. SECTIONS below is the whole list, and the page
// walks it: the tabs, the filter, the cards and the address all come from these
// entries. A new section is one more entry naming its data file and saying how
// a row reads.
//
// A descriptor says:
//   id, label        the tab, and ?section=<id>
//   source           the book line under the heading
//   files            the data/*.json files it reads (without .json)
//   groupLabel       what its filter is called ("Class", "Table")
//   build(data)      -> { rows, groups: [{ id, name }] }; every row carries .group
//   key(r)           unique within the section; ?entry=<key> opens that card
//   title, badge, meta, summary, tags, stats, related, hay   how a row reads
//   fullText(r)      optional: a power-text code, fetched when the card opens
//   bookText(r)      optional: [{ book, entry, label }], sourcebook entries whose
//                    text (msh_book_text) is fetched when the card opens
//   groupText(g)     optional: a power-text code for a filter group's introduction
//   related items    { name, code?, section?, plain? }: a code links to that key,
//                    in `section` when it is another section's (an NPC's
//                    Power); `plain` leaves the code off the link's text (a
//                    team member's card, whose key is only an id)
//   search           optional: replaces the default word search
//
// It shares the Palladium codex's idea (apps/codex/codex.js) and none of its
// code: that app belongs to another group and reads another database.

import { makeBrowser } from './browser.js';
import { makeGear } from './gear.js';

export const norm = (s) => String(s ?? '').toLowerCase().replace(/[^a-z0-9]+/g, ' ').trim();
const slug = (s) => norm(s).replace(/ /g, '-');
const band = ([lo, hi]) => (lo === hi ? String(lo) : `${lo}-${hi}`);
const d100 = (r) => band(r.roll.map((n) => String(n).padStart(2, '0')).map((s) => (s === '100' ? '00' : s)));

// A rank as the book sets it in capitals, in the case a card uses:
// "SHIFT Z" is Shift Z, "EXCELLENT" is Excellent.
const rankWords = (v) => String(v).toLowerCase().replace(/\b[a-z]/g, (c) => c.toUpperCase());

// The sourcebook sections hold every book the pipeline has read
// (scripts/msh/books.json); each row carries its book, and a card cites it by
// the book's short name (MA1). A section's source line lists the books present.
const shortOf = (books) => Object.fromEntries(books.map((b) => [b.slug, b.short]));
// A book read from several booklets (ME1) lists each with its spans:
// "ME1 Cosmos Cubed, Adventure pp.3-7, 11-28, Resource pp.2-16".
const pagesLine = (b, pages = b.pages) => (b.ranges && pages === b.pages
  ? `${b.title}, ${b.ranges.map((r) => `${r.part} pp.${r.pages.map(([x, y]) => `${x}-${y}`).join(', ')}`).join(', ')}`
  : `${b.title}, ${b.part ? `${b.part} ` : ''}pp.${pages[0]}-${pages[1]}`);

// A page as a card cites it. A boxed module numbers each booklet from 1
// (MHSP1's Adventure Book and Roster Booklet), so its rows carry the booklet
// (`part`): "MHSP1 Roster p.4". The Reference Summary has no page of its own.
// A book of one numbering reads as before: "MA1 p.7".
const cite = (short, part, pages) => {
  const p = pages.filter((n) => n !== null && n !== undefined);
  const at = p.length ? `${p.length > 1 && p[0] !== p[p.length - 1] ? 'pp.' : 'p.'}${band([p[0], p[p.length - 1]])}` : '';
  return [short, part, at].filter(Boolean).join(' ');
};

// An override's field, as a card names it.
const FIELD = { health: 'Health', karma: 'Karma', F: 'Fighting', A: 'Agility', S: 'Strength', E: 'Endurance',
  R: 'Reason', I: 'Intuition', P: 'Psyche', RIP: 'Reason, Intuition and Psyche',
  RI: 'Reason and Intuition', FAS: 'Fighting, Agility and Strength', FASE: 'Fighting, Agility, Strength and Endurance' };

// A version's name on a card: the book's parenthetical, capitalised the one
// way (MA1 prints both "(original)" and "(Current)"), or its first identity line.
const versionName = (v) => (v.label ? v.label.charAt(0).toUpperCase() + v.label.slice(1) : v.identity[0] || '');

// The Gear tab's column names, and the ones the tables abbreviate.
const HEAD = { special_damage: 'Special damage' };
const head = (c) => HEAD[c] || c.charAt(0).toUpperCase() + c.slice(1);

export const SECTIONS = [
  {
    id: 'powers',
    label: 'Powers',
    source: 'The Ultimate Powers Book, pp.18-100',
    files: ['powers', 'power-tables'],
    groupLabel: 'Class',
    build(data) {
      const browser = makeBrowser(data.powers, data['power-tables']);
      this.browser = browser;
      return {
        rows: data.powers.powers.map((p) => ({ ...p, group: p.class })),
        groups: browser.classes.map((c) => ({ id: c.code, name: `${c.name} (${c.code})` })),
      };
    },
    key: (r) => r.code,
    title: (r) => r.name,
    badge: (r) => r.code,
    meta(r) { return this.browser.className[r.class]; },
    summary: (r) => r.summary,
    tags: (r) => [r.double && 'x2', r.addenda && 'addenda'].filter(Boolean),
    stats: (r) => [
      ['Page', `UPB p.${r.page}`],
      ['Range column', r.range || 'none named'],
      ['Power slots', r.double ? 'Two' : 'One'],
      r.addenda && ['Addenda', 'Rewritten by the Dragon #122 addenda'],
    ],
    related(r) {
      return [['Bonus', 'bonus'], ['Optional', 'optional'], ['Nemesis', 'nemesis']]
        .map(([label, kind]) => [label, this.browser.related(r, kind)])
        .filter(([, items]) => items.length);
    },
    hay: (r) => `${r.code} ${r.name} ${r.summary}`,
    fullText: (r) => r.code,
    groupText: (g) => g,
    // The power browser's own search: an exact code wins, and name hits come
    // before summary hits. The codex should find what the Powers tab finds.
    search(rows, { query, group }) {
      return this.browser.search({ query, cls: group }).map((p) => rows.find((r) => r.code === p.code));
    },
  },
  {
    id: 'talents',
    label: 'Talents',
    source: "The Players' Book, p.10 and Appendix B",
    files: ['talents'],
    groupLabel: 'Category',
    build(data) {
      const t = data.talents;
      this.groupName = Object.fromEntries(t.groups.map((g) => [g.id, g.name]));
      return { rows: t.talents, groups: t.groups.map((g) => ({ id: g.id, name: g.name })) };
    },
    key: (r) => r.id,
    title: (r) => r.name,
    meta(r) { return this.groupName[r.group]; },
    summary: (r) => r.summary,
    tags: (r) => [r.double && 'x2'],
    stats: (r) => [
      ['Roll', `${band(r.roll)} on the category's d10`],
      ['Talent slots', r.double ? 'Two' : 'One'],
      r.table_name && ['On the category table', r.table_name],
    ],
    hay: (r) => `${r.name} ${r.table_name || ''} ${r.summary}`,
  },
  {
    id: 'contacts',
    label: 'Contacts',
    source: "The Players' Book, pp.10-11 and Appendix C",
    files: ['contacts'],
    groupLabel: 'Kind',
    build(data) {
      const c = data.contacts;
      this.groupName = Object.fromEntries(c.groups.map((g) => [g.id, g.name]));
      return { rows: c.contacts, groups: c.groups };
    },
    key: (r) => r.id,
    title: (r) => r.name,
    meta(r) { return this.groupName[r.group]; },
    summary: (r) => r.summary,
    hay: (r) => `${r.name} ${r.summary}`,
  },
  {
    id: 'weaknesses',
    label: 'Weaknesses',
    source: 'The Ultimate Powers Book, pp.12-13',
    files: ['weakness'],
    groupLabel: 'Roll',
    build(data) {
      const w = data.weakness;
      const groups = [
        { id: 'stimulus', name: 'What sets it off' },
        { id: 'effect', name: 'What it does' },
        { id: 'duration', name: 'How long it lasts' },
      ];
      this.groupName = Object.fromEntries(groups.map((g) => [g.id, g.name]));
      return { rows: groups.flatMap((g) => w[g.id].map((r) => ({ ...r, group: g.id }))), groups };
    },
    key: (r) => `${r.group}-${r.id}`,
    title: (r) => r.name,
    meta(r) { return this.groupName[r.group]; },
    summary: (r) => r.summary,
    stats: (r) => [['Roll', `d100 ${d100(r)}`]],
    hay: (r) => `${r.name} ${r.summary}`,
  },
  {
    id: 'gear',
    label: 'Gear and vehicles',
    source: "The Players' Book, pp.42-49",
    files: ['equipment', 'ranks'],
    groupLabel: 'Table',
    build(data) {
      const gear = makeGear(data.equipment, data.ranks);
      this.tableOf = Object.fromEntries(gear.tables.map((t) => [t.id, t]));
      this.rankOf = gear.rankOf;
      const seen = new Map();
      const rows = gear.tables.flatMap((t) => t.rows.map((r) => {
        const base = `${t.id}-${slug(r.name)}`;
        const n = (seen.get(base) || 0) + 1;
        seen.set(base, n);
        return { ...r, group: t.id, key: n === 1 ? base : `${base}-${n}` };
      }));
      return { rows, groups: gear.tables.map((t) => ({ id: t.id, name: t.name })) };
    },
    key: (r) => r.key,
    title: (r) => r.name,
    meta(r) { return `${this.tableOf[r.group].name}, PB p.${this.tableOf[r.group].page}`; },
    // The line printed under a name, or, for a row with none (most vehicles),
    // its first few figures, so a closed card still says what the thing is.
    summary(r) {
      const printed = [r.notes, r.includes && `Includes ${r.includes}`].filter(Boolean).join('. ');
      return printed || this.stats(r).filter(([, v]) => v !== null).slice(0, 4)
        .map(([k, v]) => `${k} ${v.replace(/ \(.+\)$/, '')}`).join(', ');
    },
    // Every printed column but the name, in the table's order, with a rank
    // abbreviation read back onto the ladder as the Gear tab does.
    stats(r) {
      return this.tableOf[r.group].columns.slice(1).map((c) => {
        const v = r[c];
        const rank = this.rankOf(v);
        return [head(c), v === undefined || v === null || v === '' ? null : rank ? `${v} (${rank.name})` : String(v)];
      });
    },
    hay: (r) => Object.values(r).join(' '),
  },
  {
    id: 'npcs',
    label: 'Notable NPCs',
    source: 'MA1 Children of the Atom, pp.4-81',
    files: ['npcs', 'powers'],
    groupLabel: 'Team',
    // One row per printed name. Its versions are the book's entries under that
    // name (Phoenix original and current), each with its stat blocks (forms and
    // tiers: Ursa Major's Human and Bear Form, the Brood's three). The prose is
    // not in data/npcs.json - it is the book's - and each card fetches it from
    // msh_book_text through bookText below.
    build(data) {
      const n = data.npcs;
      this.short = shortOf(n.books);
      this.many = n.books.length > 1;
      this.source = n.books.map((b) => pagesLine(b)).join('; ');
      this.upbName = Object.fromEntries(data.powers.powers.map((p) => [p.code, p.name]));
      return {
        rows: n.characters.map((c) => ({ ...c, group: slug(c.team) })),
        groups: n.teams.map((t) => ({ id: slug(t), name: t })),
      };
    },
    key: (r) => r.id,
    title: (r) => r.name,
    badge: (r) => (r.versions.length > 1 ? `${r.versions.length} versions` : ''),
    meta(r) {
      const pages = [...new Set(r.versions.flatMap((v) => v.pages))].sort((a, b) => a - b);
      return `${r.team}, ${cite(this.short[r.book], r.versions[0].part, pages)}`;
    },
    // The name and status lines printed under the header: "Kurt Wagner. Mutant
    // hero". A line that starts lower-case continues the one before it, as
    // Phoenix's "Alien entity who had assumed the personality / of Jean Grey".
    // A character only MHSP1's Reference Summary gives has no such lines.
    summary: (r) => r.versions[0].identity
      .reduce((s, l) => (!s ? l : /^[a-z(]/.test(l) && !/^\(real/i.test(l) ? `${s} ${l}` : `${s.replace(/\.$/, '')}. ${l}`), '')
      || (r.summary_only ? `In the ${r.versions[0].part || 'Reference Summary'} only; the boxed rules have the full entry`
        // a character filed under its book's title (ME1's chapter opponents) has no team to be one of
        : r.team.startsWith(`${r.book.toUpperCase()} `) ? `Statted in ${r.team}`
          : `One of the ${r.member_of || r.team}`),
    tags(r) {
      return [
      this.many && this.short[r.book],
      r.versions.some((v) => v.blocks.length > 1) && 'forms',
      r.versions.some((v) => v.members.length) && 'team',
      r.versions.some((v) => v.blocks.some((b) => b.override && b.override.verdict === 'misprint')) && 'misprint',
      r.summary_only && 'summary only',
      ];
    },
    stats(r) {
      const out = [];
      for (const v of r.versions) {
        for (const b of v.blocks) {
          // a block printed in another booklet than its character (Ben Grimm,
          // in the Adventure Book's note on the Thing) says where
          const where = b.part ? `${b.part} p.${b.page}` : '';
          const head = [r.versions.length > 1 && versionName(v), b.label, where].filter(Boolean).join(', ');
          // a rank the page does not print at all is a dash (MA4's New Men)
          const grid = b.abilities.map(([l, n, c, alt]) => (n === null ? `${l} -`
            : `${l} ${n} ${c || '?'}${alt ? ` (${alt[0]} ${alt[1] || ''})` : ''}`)).join(' | ');
          out.push([head || 'Abilities', grid]);
          out.push(['Health / Karma', `${b.health ?? '-'} / ${b.karma ?? '-'}`]);
          out.push(['Resources / Popularity', `${b.resources ?? '-'} / ${b.popularity ?? '-'}`]);
          if (b.rank_only) out.push(['Numbers', 'The book prints ranks only; each number is its rank\'s standard number']);
          const o = b.override;
          const field = o && (FIELD[o.field] || o.field);
          const show = (x) => (typeof x === 'object' ? `${x.number} ${x.code}` : x);
          if (o && o.verdict === 'misprint') {
            out.push(['Misprint', `${field} is printed ${show(o.printed)}; the book's own ranks give ${show(o.corrected)}`]);
          } else if (o && o.verdict === 'as_printed' && o.corrected) {
            // printed as no rank at all (Lockheed's "?" Reason), played as Karma counts it
            out.push(['As printed', `${field} is printed ${o.printed}; played as ${show(o.corrected)}, as the printed Karma counts it`]);
          } else if (o && o.verdict === 'rows' && !o.corrected) {
            // rows the book leaves to the GM (MA4's New Men: the animal's)
            out.push(['As printed', `${field} are printed as "${o.printed}"; the book leaves them to the GM`]);
          } else if (o && o.verdict === 'rows') {
            // a grid that prints one line for several rows (ME1's Oolafat)
            out.push(['As printed', `${field} are printed as "${o.printed}"; played as ${show(o.corrected)}, as the printed Karma counts them`]);
          } else if (o && o.verdict === 'as_printed' && typeof o.printed === 'object') {
            // a rank's number inside its range, not its standard one (ME1's Superkree)
            out.push(['As printed', `${field} is printed ${show(o.printed)}, inside the rank's range`]);
          } else if (o && o.verdict === 'as_printed') {
            out.push(['As printed', `${field} ${o.printed}, which R+I+P does not give`]);
          }
          for (const x of (o && o.also) || []) out.push(['As printed', `${FIELD[x.field] || x.field} ${x.printed}, which R+I+P does not give`]);
          // A team member the book gives no block of its own: its team's tier,
          // with the ranks its own text states (scripts/msh/<slug>-members.json).
          const f = b.built_from;
          if (f) {
            const ch = Object.entries(f.changes).map(([l, c]) => `${FIELD[l]} ${c}`).join(', ');
            out.push(['Built from', `${f.tier}, p.${f.page}${ch ? `, with ${ch} as its text states` : ', as printed'}${
              f.printed_health ? `; the text's Health ${f.printed_health} agrees` : ''}`]);
          }
        }
      }
      for (const a of r.appearances) out.push(['Also appears', `${a.team}, p.${a.page}`]);
      return out;
    },
    related(r) {
      const out = [];
      for (const v of r.versions) {
        const prefix = r.versions.length > 1 ? `${versionName(v)}: ` : '';
        if (v.powers.length) {
          const named = (p) => (p.rank ? `${p.name} (${p.rank})` : p.name);
          out.push([`${prefix}Powers`, v.powers.map((p) => (p.upb
            ? { name: named(p), code: p.upb, section: 'powers', title: `UPB ${p.upb} ${this.upbName[p.upb]}` }
            : { name: named(p) }))]);
        }
        if (v.members.length) {
          out.push([`${prefix}Members`, v.members.map((m) => (m.id
            ? { name: `${m.name} (p.${m.page})`, code: m.id, section: 'npcs', plain: true }
            : { name: `${m.name} (p.${m.page})` }))]);
        }
        // a later book's team card has an id of its own (wrecking-crew-mhsp1)
        if (r.member_of) out.push(['Team', [{ name: r.member_of, code: r.member_of_id || slug(r.member_of), section: 'npcs', plain: true }]]);
      }
      return out;
    },
    hay: (r) => [r.name, r.team, ...r.versions.flatMap((v) => [v.label, ...v.identity,
      ...v.powers.map((p) => p.name), ...v.members.map((m) => m.name)])].filter(Boolean).join(' '),
    // Each version's entry, and each cross-reference, in the book's own text.
    // A version with no text rows (ME1's chart-only heroes) asks for none, so
    // the card does not say the text is missing when the book prints none.
    bookText(r) {
      return [...r.versions.filter((v) => v.text.length).map((v) => ({ book: r.book, entry: v.id, label: r.versions.length > 1 ? versionName(v) : '' })),
        ...r.appearances.map((a) => ({ book: r.book, entry: a.id, label: `${a.team}, p.${a.page}` }))];
    },
  },
  {
    id: 'items',
    label: 'Items and locations',
    source: 'MA1 Children of the Atom, pp.82-86',
    files: ['items'],
    groupLabel: 'Kind',
    // The book's devices, vehicles and places, as data/items.json lists them:
    // facts only, with each one's text fetched from msh_book_text when its
    // card opens. A vehicle's Control, Speed and Body are printed ranks.
    build(data) {
      const n = data.items;
      this.short = shortOf(n.books);
      this.source = n.books.map((b) => pagesLine(b)).join('; ');
      const kinds = [['item', 'Special items'], ['vehicle', 'Vehicles'], ['location', 'Locations']];
      this.kindName = Object.fromEntries(kinds);
      return {
        rows: n.items.map((r) => ({ ...r, group: r.kind })),
        groups: kinds.filter(([id]) => n.items.some((r) => r.kind === id)).map(([id, name]) => ({ id, name })),
      };
    },
    key: (r) => r.id,
    title: (r) => r.name,
    meta(r) { return `${this.kindName[r.kind]}, ${cite(this.short[r.book], r.part, [r.page])}`; },
    summary(r) {
      if (r.vehicle) return Object.entries(r.vehicle).map(([k, v]) => `${k} ${rankWords(v)}`).join(', ');
      if (r.parts) return `Lists ${r.parts.join(', ')}`;
      return this.kindName[r.kind].replace(/s$/, '').replace('Special item', 'A special item');
    },
    stats(r) {
      return [
        ...(r.vehicle ? Object.entries(r.vehicle).map(([k, v]) => [k, rankWords(v)]) : []),
        ['Page', cite(this.short[r.book], r.part, [r.page])],
        // a location's room table (MHSP1's bases): one line per sector, the
        // d100 range to place a character, and each base's room there
        ...(r.rooms ? [['Sector (d100)', r.rooms.columns.join(' / ')],
          ...r.rooms.rows.map(([sec, roll, ...rooms]) => [`${sec} (${roll})`, rooms.join(' / ')])] : []),
      ];
    },
    hay: (r) => [r.name, r.kind, ...(r.parts || []), ...(r.rooms ? r.rooms.rows.flatMap((x) => x.slice(2)) : [])].join(' '),
    // A vehicle an adventure section states in passing (MHSP1's gunnery
    // platform, in First Blood) has no text of its own: its card reads that
    // section's, the only adventure text msh_book_text keeps now that the
    // adventures are gone from the app (scripts/msh/extras.py).
    bookText: (r) => [{ book: r.book, entry: r.section || r.id, label: '' }],
  },
];

// Build every section from the loaded data files ({ powers: {...}, ... }).
export function makeCodex(data, sections = SECTIONS) {
  const built = sections.map((d) => {
    const sec = Object.create(d);
    const { rows, groups } = d.build.call(sec, data);
    sec.rows = rows;
    sec.groups = groups;
    sec.byKey = new Map(rows.map((r) => [String(sec.key(r)), r]));
    return sec;
  });
  const byId = Object.fromEntries(built.map((s) => [s.id, s]));

  // Every word typed must appear in the row's hay; names that carry every word
  // come first, then the section's own order. A section may bring its own.
  function search(id, { query = '', group = '' } = {}) {
    const sec = byId[id];
    if (!sec) return [];
    if (sec.search) return sec.search(sec.rows, { query, group });
    const words = norm(query).split(' ').filter(Boolean);
    const hits = sec.rows.filter((r) => (!group || r.group === group)
      && words.every((w) => norm(sec.hay(r)).includes(w)));
    if (!words.length) return hits;
    const inName = (r) => (words.every((w) => norm(sec.title(r)).includes(w)) ? 0 : 1);
    return hits.map((r, i) => [r, i]).sort((a, b) => inName(a[0]) - inName(b[0]) || a[1] - b[1]).map(([r]) => r);
  }

  return { sections: built, byId, search };
}

// Every data file the sections read, once.
export const dataFiles = (sections = SECTIONS) => [...new Set(sections.flatMap((s) => s.files))];

// ---------------------------------------------------------------- the address

// ?section=powers&q=flight&group=T&entry=T21. A value the page does not offer
// is dropped rather than trusted, so an old or hand-typed link lands on a
// working view instead of an empty one.
export function readState(search, codex) {
  const p = new URLSearchParams(search);
  const sec = codex.byId[p.get('section')] || codex.sections[0];
  const group = p.get('group') || '';
  const entry = p.get('entry') || '';
  return {
    section: sec.id,
    q: (p.get('q') || '').slice(0, 100),
    group: sec.groups.some((g) => g.id === group) ? group : '',
    entry: sec.byKey.has(entry) ? entry : '',
  };
}

export function writeState({ section, q, group, entry }) {
  const p = new URLSearchParams();
  p.set('section', section);
  if (q) p.set('q', q);
  if (group) p.set('group', group);
  if (entry) p.set('entry', entry);
  return `?${p}`;
}
