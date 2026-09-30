// A Notable NPC from a sourcebook (data/npcs.json), as a campaign NPC sheet:
// the same snapshot shape a hero has (js/sheet.js), with mode 'book', so the
// sheet renderer, the GM roster, initiative and FEATs take it as they take a
// rolled NPC. Pure: the endpoint (functions/api/marvel-heroes/campaigns/[id]/
// npcs/from-book.js) loads the data and writes the row, and the suite runs this.
//
// What a book NPC is, and is not:
//   - its abilities are the printed numbers, placed on the ladder by the
//     number's range (PB p.2), not by the printed code - so a misprinted code
//     (Poltergeist's S 4 Ty) cannot put a number on the wrong rank.
//   - where the book's own arithmetic exposed a misprint (npcs.json
//     `override`), the CORRECTED value is used: this sheet is for play. The
//     codex card shows what the page prints.
//   - a version whose blocks are forms (Human Form and Bear Form, Phase I-III)
//     is one NPC with forms, as a Changeling hero is. A version whose blocks
//     are tiers (the Brood's member, hunter and queen) is several kinds of NPC,
//     so the GM picks one block.
//   - it has no body type, origin or weakness - the book gives none - and its
//     Powers carry no rank, because the book gives a Power's rank in prose. A
//     Power with a UPB equivalent carries that code.

import { SNAPSHOT_VERSION } from './sheet.js';

export const NPC_BOOK_DATA = ['npcs', 'ranks'];
const LETTERS = ['F', 'A', 'S', 'E', 'R', 'I', 'P'];
const KEYS = ['fighting', 'agility', 'strength', 'endurance', 'reason', 'intuition', 'psyche'];
const FORMS = /\b(form|phase)\b/i;

// A printed number; "2,150 (Varies)" is 2150 (Galactus, MHSP1).
const int = (s) => {
  const m = String(s ?? '').replace(/\u2013|\u2014/g, '-').replace(/(\d),(\d{3})\b/g, '$1$2').match(/^\s*([-+]?\d+)\b/);
  return m ? Number(m[1]) : null;
};

// A version's blocks, as the GM chooses among them: every block is its own
// choice unless they are all forms of one being - by their labels (Human
// Form, Phase II), or because the data says so (`form`: She-Hulk and Jennifer
// Walters, MHSP1).
export function isForms(version) {
  return version.blocks.length > 1 && version.blocks.every((b) => b.form || FORMS.test(b.label || ''));
}

// Every NPC the book offers, for the GM's picker: one line per character, per
// version, and per block where the blocks are tiers.
export function bookChoices(npcs) {
  const out = [];
  // Two books' same-named characters are two cards (and two choices); the
  // label names the book when a name is in more than one.
  const short = Object.fromEntries(npcs.books.map((b) => [b.slug, b.short]));
  const books = new Map();
  for (const c of npcs.characters) books.set(c.name, new Set([...(books.get(c.name) || []), c.book]));
  for (const c of npcs.characters) {
    for (const v of c.versions) {
      const vName = c.versions.length > 1 ? ` (${v.label || v.identity[0] || v.id})` : '';
      // A partial grid (MA4's New Men print only Reason, Intuition and Psyche:
      // the physical ranks are the animal's) is on the Codex card, but there
      // is no NPC to build from it, so the GM is not offered it.
      const blocks = isForms(v) ? [null] : v.blocks.map((b, i) => i).filter((i) => v.blocks[i].kind !== 'partial');
      for (const i of blocks) {
        const bl = i === null || v.blocks.length === 1 ? '' : ` - ${v.blocks[i].label || `block ${i + 1}`}`;
        const bk = books.get(c.name).size > 1 ? ` [${short[c.book]}]` : '';
        out.push({ character: c.id, version: v.id, block: i === null || v.blocks.length === 1 ? null : i,
          label: `${c.name}${vName}${bl}${bk}`, team: c.team });
      }
    }
  }
  return out;
}

export function makeBookNpc(data) {
  const ladder = data.ranks.ranks;
  // Class 5000 has no upper bound (max null), so a number above it is Class 5000
  // too (ME1's Ego, Endurance 5000); Beyond has no range and is never found.
  const rankOf = (n) => (n === null || n < 0 ? null
    : ladder.find((r) => r.min !== null && n >= r.min && (r.max === null || n <= r.max)) || null);
  const ability = (n) => {
    const r = rankOf(n);
    return { rank: r ? r.id : null, name: r ? r.name : String(n), number: n };
  };

  function block(b) {
    const fix = b.override && b.override.verdict === 'misprint' ? b.override : null;
    const abilities = {};
    b.abilities.forEach(([letter, n], i) => {
      const corrected = fix && fix.field === letter && typeof fix.corrected === 'object' ? fix.corrected.number : n;
      abilities[KEYS[i]] = ability(corrected);
    });
    // Resources prints as a rank and a number, "Pr (4)"; the number is the
    // measure. MHSP1 prints the rank alone ("POOR", "CLASS 1000"): its standard
    // number. "None" and a dash are kept as printed, with no number.
    const named = ladder.find((r) => r.name.toLowerCase() === String(b.resources ?? '').trim().toLowerCase());
    const resN = named ? named.standard : int((String(b.resources ?? '').match(/\((\d+)\)/) || [])[1]);
    const resR = rankOf(resN);
    abilities.resources = { rank: resR ? resR.id : null, name: resR ? resR.name : (b.resources || 'None'), number: resN };
    const popN = int(b.popularity);
    abilities.popularity = { rank: null, name: b.popularity || '0', number: popN };
    const printedH = int(b.health);
    const printedK = int(b.karma);
    const health = fix && fix.field === 'health' ? fix.corrected : printedH;
    const karma = fix && fix.field === 'karma' ? fix.corrected : printedK;
    return { abilities, health, karma };
  }

  // -> { build, snapshot, name } or { error }
  return function bookNpc({ character, version, block: which } = {}) {
    const c = data.npcs.characters.find((x) => x.id === character);
    if (!c) return { error: `The book has no character "${character}"` };
    const v = version ? c.versions.find((x) => x.id === version) : c.versions.length === 1 ? c.versions[0] : null;
    if (!v) return { error: `${c.name} has ${c.versions.length} versions; say which` };
    const forms = isForms(v);
    let chosen = 0;
    if (!forms && v.blocks.length > 1) {
      if (!Number.isInteger(which) || !v.blocks[which]) return { error: `${c.name} has ${v.blocks.length} stat blocks; say which` };
      chosen = which;
    }
    const first = block(v.blocks[forms ? 0 : chosen]);
    const vLabel = v.label ? v.label.charAt(0).toUpperCase() + v.label.slice(1) : '';
    const bLabel = !forms && v.blocks.length > 1 ? v.blocks[chosen].label : '';
    const name = [c.name, vLabel && `(${vLabel})`, bLabel && `- ${bLabel}`].filter(Boolean).join(' ');
    // Where the block is printed. A boxed module's booklets are each numbered
    // from 1, so the booklet goes with the page ("Roster p.4"); a Summary-only
    // character has the booklet alone.
    const at = v.blocks[forms ? 0 : chosen];
    const part = at.part || v.part;
    const snapshot = {
      v: SNAPSHOT_VERSION,
      mode: 'book',
      book: { slug: c.book, source: data.npcs.books.find((b) => b.slug === c.book).title, character: c.id, version: v.id,
        block: forms ? null : chosen, page: at.page, team: c.team,
        ...(part ? { cite: [part, at.page !== null && at.page !== undefined && `p.${at.page}`].filter(Boolean).join(' ') } : {}) },
      body: null, origin: null, weakness: null,
      abilities: first.abilities,
      health: first.health, karma: first.karma,
      forms: forms ? v.blocks.map((b) => ({ name: b.label, variant: null, ...block(b) })) : null,
      // A Power carries a rank only where the book's text states one with it
      // (Amphibus's Monstrous Leaping, scripts/msh/<slug>-members.json).
      powers: v.powers.map((p) => {
        const r = p.rank ? ladder.find((x) => x.abbr === p.rank) : null;
        return { code: p.upb || '', name: p.name, rank: r ? r.id : null, rankName: r ? r.name : '', number: r ? r.standard : null,
          slots: 1, source: 'book' };
      }),
      talents: [], contacts: [],
    };
    return { name, snapshot, build: { mode: 'book', book: c.book, character: c.id, version: v.id, block: forms ? null : chosen } };
  };
}
