// The saved hero and its sheet. Pure: no DOM, no fetch, so the smoke suite can
// run it in Node.
//
// snapshot() turns what the generator built into plain names and numbers. The
// saved row keeps it beside the generator state, and the sheet draws only from
// it, so a later correction to the app's tables cannot change a saved hero.
//
// renderSheet() lays that out after the Judge's Book character sheet: the seven
// abilities with rank and points, a second form, the four variable abilities,
// Karma pool and Advancement fund, Powers, Talents and Contacts, and the
// identity lines down the side.

import { PRIMARY } from './generator.js';

export const SNAPSHOT_VERSION = 1;
const VARIABLE = ['resources', 'popularity'];
const LABEL = { fighting: 'Fighting', agility: 'Agility', strength: 'Strength', endurance: 'Endurance',
  reason: 'Reason', intuition: 'Intuition', psyche: 'Psyche', resources: 'Resources', popularity: 'Popularity' };

// The identity lines on the printed sheet, in its order, with the key the
// saved sheet stores each under (functions/api/marvel-heroes/_lib/heroes.js).
export const IDENTITY = [
  ['identity', "Hero's ID"], ['player', "Player's name"], ['group', 'Group affiliation'],
  ['base', 'Base of operations'], ['occupation', 'Occupation'], ['birthplace', 'Place of birth'],
  ['legal_status', 'Legal status'], ['marital_status', 'Marital status'], ['age', 'Age'],
  ['height', 'Height'], ['weight', 'Weight'],
];

export function snapshot(h, gen, data, contactPicks = []) {
  const rankName = (id) => gen.ladder.find((r) => r.id === id)?.name ?? id;
  const byId = (list, id) => list.find((x) => x.id === id);
  const ability = (v) => ({ rank: v.rank, name: rankName(v.rank), number: v.number });
  const set = (ab) => Object.fromEntries([...PRIMARY, ...VARIABLE].map((k) => [k, ability(ab[k])]));
  const origin = byId(data.origins.origins, h.origin.id);
  return {
    v: SNAPSHOT_VERSION,
    body: {
      id: h.body.id, name: h.body.name, variant: h.body.variantName, special: h.body.special || null,
      aspects: h.body.special ? h.body.aspects.map((x) => gen.typeById[x.id].name) : [],
      notes: h.body.notes || [],
    },
    origin: { id: origin.id, name: origin.name },
    abilities: set(h.abilities),
    health: h.health, karma: h.karma,
    forms: h.forms ? h.forms.map((f) => ({ name: f.name, variant: f.variantName, abilities: set(f.abilities), health: f.health, karma: f.karma })) : null,
    powers: h.powers.map((p) => ({
      code: p.code, name: gen.powerByCode[p.code].name, rank: p.rank, rankName: rankName(p.rank),
      number: gen.numberOf(p.rank), slots: p.slots, source: p.source,
      ...(p.form !== undefined && h.forms ? { form: h.forms[p.form].name } : {}),
    })),
    talents: h.talents.map((x) => {
      const t = byId(data.talents.talents, x.id);
      return { id: t.id, name: t.name, group: byId(data.talents.groups, t.group).name };
    }),
    contacts: Array.from({ length: h.contacts.slots }, (_, i) => {
      const c = contactPicks[i] && byId(data.contacts.contacts, contactPicks[i]);
      return c ? { id: c.id, name: c.name } : null;
    }),
    weakness: Object.fromEntries(['stimulus', 'effect', 'duration'].map((k) => [k, byId(data.weakness[k], h.weakness[k].id).name])),
    seeds: { ...h.seeds },
  };
}

// A one-line description for a list of heroes.
export function tagline(s) {
  const body = s.body.special ? `${s.body.special === 'compound' ? 'Compound' : 'Changeling'} (${s.body.aspects.join(', ')})`
    : `${s.body.name}${s.body.variant ? ` (${s.body.variant})` : ''}`;
  return `${body}, ${s.origin.name}; ${s.powers.length} Power${s.powers.length === 1 ? '' : 's'}`;
}

const ordinal = (n) => ({ 1: '1st', 2: '2nd', 3: '3rd' }[n] || `${n}th`);   // a Changeling has at most a handful of forms

export const esc = (s) => String(s ?? '').replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));

// The sheet as HTML. `sheet` is the saved written fields; every one is an
// editable input carrying data-field, which the page reads back to save.
export function renderSheet({ name, snapshot: s, sheet = {} }) {
  const field = (key, label, attrs = '') => `<label class="sh-line"><span>${esc(label)}</span>
      <input type="text" data-field="${key}" value="${esc(sheet[key])}" ${attrs}></label>`;
  const abilityRows = (ab) => PRIMARY.map((k) => `<tr><th scope="row" title="${LABEL[k]}">${LABEL[k][0]}<span class="sr-only">${LABEL[k].slice(1)}</span></th>
      <td>${esc(ab[k].name)}</td><td class="num">${ab[k].number}</td></tr>`).join('');
  const abilities = (ab, caption) => `<table class="sh-faserip"><caption>${esc(caption)}</caption>
      <thead><tr><th></th><th>Rank</th><th class="num">Points</th></tr></thead><tbody>${abilityRows(ab)}</tbody></table>`;
  const forms = s.forms && s.forms.length > 1
    ? s.forms.slice(1).map((f, i) => abilities(f.abilities, `${ordinal(i + 2)} form: ${f.name}`)).join('')
    : `<div class="sh-form2">${field('second_form', '2nd form', 'placeholder="Trigger, and whether it is controlled"')}</div>`;
  const box = (label, value, sub = '') => `<div class="sh-box"><span class="sh-label">${esc(label)}</span><strong>${esc(value)}</strong>${sub ? `<span class="muted">${esc(sub)}</span>` : ''}</div>`;
  const num = (key, label, start) => `<label class="sh-box"><span class="sh-label">${esc(label)}</span>
      <input type="number" inputmode="numeric" data-number="${key}" value="${Number.isInteger(sheet[key]) ? sheet[key] : ''}" placeholder="${start ?? ''}"></label>`;
  const list = (items, empty) => (items.length ? `<ul class="sh-list">${items.join('')}</ul>` : `<p class="muted">${empty}</p>`);
  return `
    <article class="sheet" aria-label="Character sheet: ${esc(name)}">
      <header class="sh-head">
        <div><span class="caption">Marvel Super Heroes</span>
          <h2 class="sh-name">${esc(name)}</h2>
          <p class="muted">${esc(tagline(s))}</p></div>
      </header>
      <div class="sh-top">
        <div class="sh-stats">
          ${abilities(s.abilities, s.forms ? `1st form: ${s.forms[0].name}` : 'Primary abilities')}
          ${forms}
        </div>
        <div class="sh-identity">${IDENTITY.map(([k, l]) => field(k, l)).join('')}</div>
      </div>
      <div class="sh-boxes">
        ${box('Health', s.health)}${box('Karma', s.karma)}
        ${box('Resources', s.abilities.resources.name)}${box('Popularity', `${s.abilities.popularity.name} (${s.abilities.popularity.number})`)}
      </div>
      <div class="sh-boxes play">
        ${num('health', 'Health now', s.health)}${num('karma', 'Karma now', s.karma)}
        ${num('karma_pool', 'Karma pool', 0)}${num('advancement', 'Advancement fund', 0)}
      </div>
      <div class="sh-bottom">
        <section class="sh-powers"><h3>Powers</h3>${list(s.powers.map((p) => `<li><strong>${esc(p.name)}</strong> <span class="code">${esc(p.code)}</span>
            ${esc(p.rankName)} (${p.number})${p.form ? ` <span class="muted">${esc(p.form)} form</span>` : ''}</li>`), 'None.')}
          <h3>Weakness</h3><p>${esc(s.weakness.stimulus)}; ${esc(s.weakness.effect)}; ${esc(s.weakness.duration)}</p>
          ${s.body.notes.length ? `<h3>Body</h3><ul class="sh-list">${s.body.notes.map((n) => `<li>${esc(n)}</li>`).join('')}</ul>` : ''}
        </section>
        <section class="sh-side">
          <h3>Contacts</h3>${list(s.contacts.map((c) => `<li>${c ? esc(c.name) : '<span class="muted">to choose</span>'}</li>`), 'None.')}
          <h3>Talents</h3>${list(s.talents.map((t) => `<li>${esc(t.name)} <span class="muted">${esc(t.group)}</span></li>`), 'None.')}
        </section>
      </div>
      <label class="sh-long"><span class="sh-label">Background</span><textarea data-field="background" rows="4">${esc(sheet.background)}</textarea></label>
      <label class="sh-long"><span class="sh-label">Notes</span><textarea data-field="notes" rows="3">${esc(sheet.notes)}</textarea></label>
    </article>`;
}
