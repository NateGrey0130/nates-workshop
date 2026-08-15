// Character creation wizard: system → class → attributes → skills →
// equipment → powers → review/save.
//
// ES module so it can share js/dice.js with the server-side leveling code
// (functions/api/character-creator/_lib/leveling.js imports the same file).
// /shared/js/ui.js loads first as a classic script, so escHtml() is global;
// inline onclick handlers need their entry points on window — see the
// Object.assign at the bottom.
import { d, evalDice } from './js/dice.js';
import { isChoiceGroup } from './js/parser.js';

const ATTRS = ['IQ', 'ME', 'MA', 'PS', 'PP', 'PE', 'PB', 'Spd'];
const STEPS = ['System', 'Class', 'Attributes', 'Skills', 'Equipment', 'Powers', 'Details', 'Review'];

// The printed sheet's identity block. Everything here is optional flavour —
// nothing in the app's rules depends on it.
const BIO_FIELDS = [
  ['race', 'Race'], ['alignment', 'Alignment'], ['true_name', 'True Name'],
  ['occupation', 'Occupation'], ['age', 'Age'], ['sex', 'Sex'],
  ['height', 'Height'], ['weight', 'Weight'],
  ['family_origin', 'Family Origin'], ['environment', 'Environment'],
  ['native_languages', 'Native Language(s)'], ['insanity', 'Insanity (if any)'],
];
// Point-buy (house rule — Palladium has no native point-buy):
// all 8 attributes start at 8; 40-point pool; +1 costs 1 point up to 15,
// 2 points from 16-18 (cap 18, floor 3); lowering below 8 refunds 1/point.
const PB_POOL = 40, PB_BASE = 8, PB_CAP = 18, PB_FLOOR = 3;

const S = {
  step: 0, system: null, classMode: 'browse', quiz: [null, null, null],
  classes: [], cls: null,
  attrMethods: {}, attrs: {},
  related: [], secondary: [], groupPicks: {},
  equipment: [], equipInit: false,
  charName: '', campaignId: null, newCampaign: '',
  spells: [], psi: [], bio: {},
  pools: null, savedId: null, saving: false,
  skillCatalog: [], items: [], campaigns: [], existing: [],
  spellCatalog: [], psiCatalog: [], me: null, isAdmin: false,
};

const $ = (id) => document.getElementById(id);
const esc = escHtml; // from /shared/js/ui.js

async function api(path, opts) {
  const res = await fetch('/api/character-creator/' + path, opts);
  const data = await res.json().catch(() => ({}));
  if (!res.ok) throw new Error(data.error || ('API ' + res.status));
  return data;
}

// ---------- dice ----------
// Standard Palladium attribute roll: 3d6, one bonus d6 on an exceptional 16+.
function rollStandard() {
  const t = d(6) + d(6) + d(6);
  return t >= 16 ? t + d(6) : t;
}
function rollAttr(attr) {
  const dice = S.cls?.attribute_dice?.[attr];
  return dice ? (evalDice(dice) ?? rollStandard()) : rollStandard();
}

// ---------- point-buy ----------
function pbCost(v) {
  let cost = 0;
  for (let t = PB_BASE + 1; t <= v; t++) cost += t <= 15 ? 1 : 2;
  if (v < PB_BASE) cost = -(PB_BASE - v);
  return cost;
}
function pbSpent() {
  return ATTRS.filter((a) => method(a) === 'point').reduce((sum, a) => sum + pbCost(S.attrs[a] ?? PB_BASE), 0);
}
const method = (a) => S.attrMethods[a] || 'roll';

// ---------- pools ----------
function rollPoolFormula(expr) {
  if (expr == null) return null;
  if (typeof expr === 'number') return expr;
  const s = String(expr).trim();
  const dice = evalDice(s);
  if (dice != null) return dice;
  const pe = s.match(/p\.?e\.?\s*\+\s*(\d+\s*d\s*\d+(?:\s*x\s*\d+)?(?:\s*[+-]\s*\d+)?)/i);
  if (pe) return (S.attrs.PE || 0) + evalDice(pe[1]);
  const n = Number(s);
  return Number.isFinite(n) ? n : null;
}
function computePools() {
  const c = S.cls;
  S.pools = {
    hp: rollPoolFormula(c.hit_points_base),
    sdc: rollPoolFormula(c.sdc_base),
    mdc: rollPoolFormula(c.mdc_base),
    ppe: rollPoolFormula(c.ppe_base),
    isp: c.psionics ? rollPoolFormula(c.psionics.isp_base) : null,
  };
}

// ---------- guided quiz ----------
const QUIZ = [
  { q: 'What are you playing?', opts: [['occ', 'A trained human-scale hero'], ['rcc', 'Something inhuman or monstrous'], ['any', 'No preference']] },
  { q: 'How do you want to solve problems?', opts: [['melee', 'Up close — blades and fists'], ['ranged', 'At range — bows or guns'], ['mystic', 'Magic and psychic powers']] },
  { q: 'What flavor of gear and setting?', opts: [['hightech', 'High-tech'], ['lowtech', 'Simple and traditional'], ['arcane', 'Arcane and otherworldly']] },
];
function classTraits(c) {
  const names = (c.skills?.occ_skills || []).map((s) => String(s.name).toLowerCase());
  const techy = names.some((n) => /radio|pilot|computer|laser|sensor/.test(n));
  return {
    cat: c.category,
    melee: names.some((n) => /w\.p\..*(sword|knife|blunt|shield|paired)/.test(n)),
    ranged: names.some((n) => /w\.p\..*(archery|energy|rifle|pistol|gun)/.test(n)),
    mystic: !!(c.magic || c.psionics),
    flavor: c.magic ? 'arcane' : techy ? 'hightech' : 'lowtech',
  };
}
function quizScore(c) {
  const t = classTraits(c);
  let score = 0;
  const [q1, q2, q3] = S.quiz;
  if (q1 && q1 !== 'any' && t.cat === q1) score += 2;
  if (q2 === 'melee' && t.melee) score += 2;
  if (q2 === 'ranged' && t.ranged) score += 2;
  if (q2 === 'mystic' && t.mystic) score += 2;
  if (q3 && t.flavor === q3) score += 2;
  return score;
}

// ---------- rendering ----------
function renderStepper() {
  $('stepper').innerHTML = STEPS.map((name, i) => {
    const cls = i === S.step ? 'st cur' : i < S.step ? 'st done' : 'st';
    const go = i < S.step ? ` onclick="goStep(${i})"` : '';
    return `<span class="${cls}"${go}>${i + 1}. ${name}</span>`;
  }).join('');
}

function render() {
  if (S.savedId) { renderStepper(); return renderSaved(); }
  renderStepper();
  [renderSystem, renderClass, renderAttributes, renderSkills, renderEquipment,
   renderPowers, renderDetails, renderReview][S.step]();
}

function goStep(i) { S.step = i; render(); }

// Step 0 — system
function gmCampaigns() {
  return S.me ? S.campaigns.filter((c) => c.gm_email === S.me) : [];
}
function renderSystem() {
  $('app').innerHTML = `
  <div class="panel">
    <h2>Choose a game system</h2>
    <div class="grid">
      <div class="pick ${S.system === 'palladium-fantasy' ? 'sel' : ''}" onclick="pickSystem('palladium-fantasy')">
        <h4>⚔️ Palladium Fantasy</h4><p class="muted">Swords, sorcery, and the Old Kingdom.</p>
      </div>
      <div class="pick ${S.system === 'rifts' ? 'sel' : ''}" onclick="pickSystem('rifts')">
        <h4>☢️ Rifts</h4><p class="muted">Mega-damage, magic, and machines on post-apocalyptic Earth.</p>
      </div>
    </div>
    ${S.isAdmin ? `<h3>Admin</h3>
    <p class="small"><a href="import.html">📄 Import from a PDF</a>
      <span class="muted">— pull an O.C.C./R.C.C. or a skill chapter out of a sourcebook</span></p>
    <p class="small"><a href="catalog.html">✏️ Edit catalogs</a>
      <span class="muted">— fix skills, spells, psionics and gear by hand</span></p>` : ''}
    ${gmCampaigns().length ? `<h3>Your campaigns (GM)</h3>
    <p class="small">${gmCampaigns().map((c) =>
      `<a href="dashboard.html?campaign_id=${c.id}">🗺 ${esc(c.name)}</a> <span class="muted">(${esc(c.system)})</span>`
    ).join(' &nbsp;·&nbsp; ')}</p>` : ''}
    ${S.existing.length ? `<h3>Existing characters</h3>
    <p class="small">${S.existing.map((c) =>
      `<a href="sheet.html?id=${c.id}">${esc(c.name)}</a> <span class="muted">(${esc(c.class_id)} L${c.level} · ${esc(c.campaign_name)})</span>`
    ).join(' &nbsp;·&nbsp; ')}</p>` : ''}
  </div>`;
}
function pickSystem(sys) {
  if (S.system !== sys) { S.cls = null; S.quiz = [null, null, null]; resetBuild(); }
  S.system = sys; S.step = 1; render();
}
function resetBuild() {
  S.attrMethods = {}; S.attrs = {}; S.related = []; S.secondary = []; S.groupPicks = {};
  S.equipment = []; S.equipInit = false; S.pools = null;
  S.spells = []; S.psi = []; S.bio = {};
}

// Step 1 — class select (browse | guided)
function renderClass() {
  const list = S.classes.filter((c) => c.system === S.system);
  const mode = S.classMode;
  let inner;
  if (mode === 'browse') {
    inner = `<div class="grid">` + list.map((c) => classCard(c)).join('') + `</div>`;
  } else {
    const answered = S.quiz.every((a) => a);
    inner = QUIZ.map((q, i) => `
      <h3>${i + 1}. ${q.q}</h3>
      <div class="rowline">` + q.opts.map(([val, label]) =>
        `<button class="btn btn-sm ${S.quiz[i] === val ? '' : 'btn-ghost'}" onclick="quizPick(${i},'${val}')">${label}</button>`).join('') + `</div>`).join('');
    if (answered) {
      const ranked = list.map((c) => [quizScore(c), c]).sort((x, y) => y[0] - x[0]);
      inner += `<h3>Your shortlist</h3><div class="grid">` +
        ranked.map(([score, c]) => classCard(c, score)).join('') + `</div>`;
    } else {
      inner += `<p class="muted" style="margin-top:12px">Answer all three to see your shortlist.</p>`;
    }
  }
  $('app').innerHTML = `
  <div class="panel">
    <h2>Pick your class <span class="muted small">(${esc(S.system)})</span></h2>
    <div class="toggle">
      <button class="${mode === 'browse' ? 'on' : ''}" onclick="classMode('browse')">Browse all</button>
      <button class="${mode === 'guided' ? 'on' : ''}" onclick="classMode('guided')">Help me choose</button>
    </div>
    ${inner}
    ${S.cls ? classDetail(S.cls) : ''}
  </div>
  <div class="nav"><button class="btn btn-ghost" onclick="goStep(0)">&larr; Back</button>
  <button class="btn btn-primary" ${S.cls ? '' : 'disabled'} onclick="confirmClass()">Use this class &rarr;</button></div>`;
}
function classCard(c, score) {
  const sel = S.cls?.id === c.id ? ' sel' : '';
  const badge = score != null ? `<span class="tag score">match ${score}/6</span>` : '';
  return `<div class="pick${sel}" onclick="pickClass('${c.id}')">
    <h4>${esc(c.name)}</h4>
    <span class="tag">${esc(c.category)}</span><span class="tag">${esc(c.source_book)}</span>${badge}
    <p class="muted small">${esc((c.lore || '').split('\n')[0].slice(0, 110))}…</p>
  </div>`;
}
function classDetail(c) {
  const reqs = c.attribute_requirements
    ? Object.entries(c.attribute_requirements).map(([k, v]) => `${k} ${v}+`).join(', ') : 'none';
  const sk = c.skills || {};
  return `<div style="margin-top:16px; border-top:1px solid var(--border); padding-top:14px">
    <h3>${esc(c.name)}</h3>
    <p class="muted small">Requirements: ${esc(reqs)} &nbsp;·&nbsp; Class skills: ${(sk.occ_skills || []).length}
      &nbsp;·&nbsp; Related picks: ${sk.occ_related_skills?.count ?? 0} &nbsp;·&nbsp; Secondary picks: ${sk.secondary_skills?.count ?? 0}
      ${c.psionics ? ' · Psionics: ' + esc(c.psionics.type) : ''}${c.magic ? ' · Magic: ' + esc(c.magic.type) : ''}</p>
    <p class="small" style="margin-top:8px; line-height:1.55">${esc(c.lore || '')}</p>
    ${listOrText('Side effects', c.side_effects)}
    ${listOrText('Restrictions', c.restrictions)}
    ${c.gm_notes ? `<p class="muted small" style="margin-top:8px"><b>GM notes:</b> ${esc(c.gm_notes)}</p>` : ''}
  </div>`;
}
// side_effects / restrictions are free text — a string or a list, advisory only.
function listOrText(label, value) {
  if (!value || (Array.isArray(value) && !value.length)) return '';
  const body = Array.isArray(value)
    ? `<ul style="margin:4px 0 0 18px">${value.map((v) => `<li class="small">${esc(v)}</li>`).join('')}</ul>`
    : `<span class="small"> ${esc(value)}</span>`;
  return `<p class="small" style="margin-top:8px"><b>${label}:</b>${body}</p>`;
}

function classMode(m) { S.classMode = m; render(); }
function quizPick(i, val) { S.quiz[i] = val; render(); }
function pickClass(id) { const c = S.classes.find((x) => x.id === id); if (S.cls?.id !== id) resetBuild(); S.cls = c; render(); }
function confirmClass() { S.step = 2; render(); }

// Step 2 — attributes
function renderAttributes() {
  const reqs = S.cls.attribute_requirements || {};
  const spent = pbSpent();
  const rows = ATTRS.map((a) => {
    const m = method(a);
    const v = S.attrs[a];
    const dice = S.cls.attribute_dice?.[a];
    let control;
    if (m === 'roll') {
      control = `<button class="btn btn-sm" onclick="doRoll('${a}')">Roll ${esc(dice || '3d6')}</button> <b>${v ?? '—'}</b>`;
    } else if (m === 'point') {
      control = `<button class="btn btn-sm btn-ghost" onclick="pbAdj('${a}',-1)">−</button> <b>${v ?? PB_BASE}</b>
                 <button class="btn btn-sm btn-ghost" onclick="pbAdj('${a}',1)">+</button>`;
    } else {
      control = `<input type="number" min="1" max="40" value="${v ?? ''}" onchange="manualSet('${a}', this.value)">`;
    }
    const req = reqs[a] ? `<span class="attr-note ${v != null && v < reqs[a] ? 'err' : 'ok'}">need ${reqs[a]}+</span>` : '';
    return `<tr><td><b>${a}</b></td>
      <td><select onchange="setMethod('${a}', this.value)">
        <option value="roll" ${m === 'roll' ? 'selected' : ''}>Random roll</option>
        <option value="point" ${m === 'point' ? 'selected' : ''}>Point-buy</option>
        <option value="manual" ${m === 'manual' ? 'selected' : ''}>Manual entry</option>
      </select></td>
      <td>${control}</td><td>${req}${dice ? ` <span class="attr-note">racial dice: ${esc(dice)}</span>` : ''}</td></tr>`;
  }).join('');

  const unmet = Object.entries(reqs).filter(([k, min]) => (S.attrs[k] ?? -1) < min);
  const missing = ATTRS.filter((a) => S.attrs[a] == null);
  const usesPB = ATTRS.some((a) => method(a) === 'point');
  const over = spent > PB_POOL;
  const canNext = missing.length === 0 && unmet.length === 0 && !over;

  $('app').innerHTML = `
  <div class="panel">
    <h2>Attributes <span class="muted small">— ${esc(S.cls.name)}</span></h2>
    <div class="rowline">
      <span class="muted small">Set all to:</span>
      <button class="btn btn-sm btn-ghost" onclick="setAllMethod('roll')">Random</button>
      <button class="btn btn-sm btn-ghost" onclick="setAllMethod('point')">Point-buy</button>
      <button class="btn btn-sm btn-ghost" onclick="setAllMethod('manual')">Manual</button>
      <button class="btn btn-sm" onclick="rollAll()">🎲 Roll all random</button>
    </div>
    ${usesPB ? `<p class="small">Point-buy pool: <b class="${over ? 'err' : ''}">${PB_POOL - spent}</b> / ${PB_POOL} left
      <span class="muted">(start 8 · +1 costs 1 pt to 15, 2 pts to 18 · floor 3 · house rule)</span></p>` : ''}
    <table><tr><th>Attr</th><th>Method</th><th>Value</th><th></th></tr>${rows}</table>
    ${missing.length ? `<p class="warn">Still needed: ${missing.join(', ')}</p>` : ''}
    ${unmet.length ? `<p class="warn err">Class minimum not met: ${unmet.map(([k, v]) => `${k} ${v}+`).join(', ')}</p>` : ''}
    ${S.cls.attribute_dice && usesPB ? `<p class="muted small">Note: point-buy/manual ignore racial attribute dice — the class minimums are still enforced.</p>` : ''}
  </div>
  <div class="nav"><button class="btn btn-ghost" onclick="goStep(1)">&larr; Back</button>
  <button class="btn btn-primary" ${canNext ? '' : 'disabled'} onclick="goStep(3)">Skills &rarr;</button></div>`;
}
function setMethod(a, m) { S.attrMethods[a] = m; if (m === 'point') S.attrs[a] = S.attrs[a] ?? PB_BASE; render(); }
function setAllMethod(m) { ATTRS.forEach((a) => { S.attrMethods[a] = m; if (m === 'point') S.attrs[a] = S.attrs[a] ?? PB_BASE; }); render(); }
function doRoll(a) { S.attrs[a] = rollAttr(a); render(); }
function rollAll() { ATTRS.forEach((a) => { S.attrMethods[a] = 'roll'; S.attrs[a] = rollAttr(a); }); render(); }
function manualSet(a, v) { const n = parseInt(v, 10); S.attrs[a] = Number.isFinite(n) && n > 0 ? n : null; render(); }
function pbAdj(a, delta) {
  const cur = S.attrs[a] ?? PB_BASE;
  const next = cur + delta;
  if (next < PB_FLOOR || next > PB_CAP) return;
  S.attrs[a] = next;
  if (pbSpent() > PB_POOL && delta > 0) { S.attrs[a] = cur; return; }
  render();
}

// Step 3 — skills
function catalogFor(categories) {
  return S.skillCatalog.filter((sk) =>
    (!categories || categories.includes(sk.category)) &&
    (!sk.systems || sk.systems.includes(S.system)));
}
// Single definition, shared with the server-side validator — the two copies
// drifted once already.
const isGroup = isChoiceGroup;

// Name -> catalog entry, built once per catalog load. The skills step performs
// one lookup per rendered skill and re-renders on every toggle, so a linear
// scan here is the difference between constant and quadratic work.
let _skillIndex = null;
function skillByName() {
  if (!_skillIndex) _skillIndex = new Map(S.skillCatalog.map((sk) => [sk.name, sk]));
  return _skillIndex;
}

// Class files may omit base/per_level for a required skill — sourcebook class
// pages usually state only the bonus, with the base living in the skill table.
// Fall back to the catalog so imported classes still show real percentages.
function resolveSkill(name, explicit = {}) {
  const cat = skillByName().get(name) || {};
  return {
    base: explicit.base ?? cat.base ?? 0,
    per_level: explicit.per_level ?? cat.per_level ?? 0,
    category: cat.category || 'Class',
  };
}

// Names already spoken for: fixed class skills, every choice-group pick made so
// far, and anything chosen as related/secondary.
function takenNames() {
  const occ = (S.cls.skills?.occ_skills || [])
    .filter((s) => !isGroup(s)).map((s) => String(s.name).toLowerCase());
  const groups = Object.values(S.groupPicks).flat().map((n) => String(n).toLowerCase());
  return new Set([...occ, ...groups, ...S.related.map((n) => n.toLowerCase()), ...S.secondary.map((n) => n.toLowerCase())]);
}
function renderSkills() {
  const sk = S.cls.skills || {};
  const relatedCfg = sk.occ_related_skills || { count: 0, categories: [] };
  const secondaryCfg = sk.secondary_skills || { count: 0 };
  const taken = takenNames();

  // Fixed skills auto-populate; choice-groups ("pick N of these") get an inline
  // pick control. Either kind may carry an advisory `note`.
  const occRows = (sk.occ_skills || []).map((s, gi) => {
    const noteHtml = s.note ? `<div class="attr-note" style="margin:0 0 4px 18px">↳ ${esc(s.note)}</div>` : '';
    if (!isGroup(s)) {
      const r = resolveSkill(s.name, s);
      // A named skill with `choose` is taken that many times.
      return `<div class="chkrow">✔ <span>${esc(s.name)}${s.choose > 1 ? ` ×${s.choose}` : ''}</span>
        <span class="pct">${r.base ? r.base + '%' + (r.per_level ? ' +' + r.per_level + '/lvl' : '') : '—'}</span></div>${noteHtml}`;
    }
    const picked = S.groupPicks[gi] || [];
    // Either an enumerated `from` list, or `categories` — "two piloting skills
    // of choice" resolves against the catalog.
    const optionNames = (s.from || []).length
      ? (s.from || []).map((raw) => (typeof raw === 'string' ? raw : raw?.name))
      : catalogFor(s.categories).map((sk) => sk.name);
    const opts = optionNames.map((name) => {
      const on = picked.includes(name);
      const blocked = !on && picked.length >= s.choose;
      return `<label class="chkrow" style="${blocked ? 'opacity:0.45' : 'cursor:pointer'}; margin-left:18px">
        <input type="checkbox" ${on ? 'checked' : ''} ${blocked ? 'disabled' : ''}
          data-act="group" data-group="${gi}" data-limit="${s.choose}" data-name="${esc(name)}">
        <span>${esc(name)}</span>
        <span class="pct">${s.base ? s.base + '%' + (s.per_level ? ' +' + s.per_level + '/lvl' : '') : '—'}</span></label>`;
    }).join('');
    return `<div class="chkrow"><b>Pick ${s.choose}</b>
      <span class="pct">${esc((s.categories || []).join(', '))} ${picked.length}/${s.choose} chosen</span></div>${noteHtml}${opts}`;
  }).join('');

  const schedule = relatedCfg.schedule || [];

  const pickList = (catalog, chosen, kind, limit) => catalog.map((s) => {
    const on = chosen.includes(s.name);
    const blocked = !on && (taken.has(s.name.toLowerCase()) || chosen.length >= limit);
    return `<label class="chkrow" style="${blocked ? 'opacity:0.45' : 'cursor:pointer'}">
      <input type="checkbox" ${on ? 'checked' : ''} ${blocked ? 'disabled' : ''}
        data-act="skill" data-kind="${kind}" data-name="${esc(s.name)}">
      <span>${esc(s.name)}</span>
      <span class="pct">${s.category} · ${s.base ? s.base + '%' + (s.per_level ? ' +' + s.per_level + '/lvl' : '') : '—'}</span>
    </label>`;
  }).join('');

  $('app').innerHTML = `
  <div class="panel">
    <h2>Skills <span class="muted small">— ${esc(S.cls.name)}</span></h2>
    <h3>Class skills <span class="muted small">(automatic)</span></h3>
    ${occRows || '<p class="muted small">None listed.</p>'}
    <div class="cols" style="margin-top:14px">
      <div>
        <h3>Related skills — ${S.related.length}/${relatedCfg.count}</h3>
        <p class="muted small">Allowed: ${esc((relatedCfg.categories || []).join(', ') || '—')}</p>
        ${schedule.length ? `<p class="attr-note">Also grants ${schedule.map((s) => `+${s.count} at level ${s.level}`).join(', ')}
          — recorded on the class, not yet prompted at level-up.</p>` : ''}
        ${pickList(catalogFor(relatedCfg.categories), S.related, 'related', relatedCfg.count)}
      </div>
      <div>
        <h3>Secondary skills — ${S.secondary.length}/${secondaryCfg.count}</h3>
        <p class="muted small">Any category, base % only.</p>
        ${pickList(catalogFor(null), S.secondary, 'secondary', secondaryCfg.count)}
      </div>
    </div>
  </div>
  <div class="nav"><button class="btn btn-ghost" onclick="goStep(2)">&larr; Back</button>
  <button class="btn btn-primary" onclick="goStep(4)">Equipment &rarr;</button></div>`;
}
function toggleGroupPick(groupIndex, name, limit) {
  const list = S.groupPicks[groupIndex] || (S.groupPicks[groupIndex] = []);
  const i = list.indexOf(name);
  if (i >= 0) list.splice(i, 1);
  else if (list.length < limit) list.push(name);
  render();
}

function toggleSkill(kind, name) {
  const list = kind === 'related' ? S.related : S.secondary;
  const i = list.indexOf(name);
  if (i >= 0) list.splice(i, 1); else list.push(name);
  render();
}

// Step 4 — equipment
function initEquipment() {
  if (S.equipInit) return;
  S.equipment = (S.cls.equipment_starting || []).map((eq) => {
    const item = S.items.find((it) => it.slug === eq.item_id);
    return item
      ? { item_id: item.id, name: item.name, qty: eq.qty || 1, source: 'starting' }
      : { custom_name: eq.item_id.replace(/-/g, ' '), qty: eq.qty || 1, source: 'starting', notes: 'starting gear (not in item catalog yet)' };
  });
  S.equipInit = true;
}
function renderEquipment() {
  initEquipment();
  const rows = S.equipment.map((e, i) =>
    `<tr><td>${esc(e.name || e.custom_name)}</td><td>×${e.qty}</td>
     <td><span class="tag">${e.source}</span></td><td class="muted small">${esc(e.notes || '')}</td>
     <td><button class="btn btn-sm btn-ghost" onclick="rmEquip(${i})">✕</button></td></tr>`).join('');
  const catalogOpts = S.items.map((it) => `<option value="${it.id}">${esc(it.name)}</option>`).join('');
  $('app').innerHTML = `
  <div class="panel">
    <h2>Equipment <span class="muted small">— ${esc(S.cls.name)}</span></h2>
    <table>${rows || '<tr><td class="muted">Nothing yet.</td></tr>'}</table>
    <h3>Add from item catalog</h3>
    ${S.items.length ? `<div class="rowline">
      <select id="cat-item">${catalogOpts}</select>
      <input type="number" id="cat-qty" value="1" min="1">
      <button class="btn btn-sm" onclick="addCatalog()">Add</button>
    </div>` : '<p class="muted small">Catalog is empty for this system.</p>'}
    <h3>Add custom item</h3>
    <div class="rowline">
      <input type="text" id="cust-name" placeholder="Name">
      <input type="text" id="cust-notes" placeholder="Notes (optional)" style="width:190px">
      <input type="number" id="cust-qty" value="1" min="1">
      <button class="btn btn-sm" onclick="addCustom()">Add</button>
    </div>
  </div>
  <div class="nav"><button class="btn btn-ghost" onclick="goStep(3)">&larr; Back</button>
  <button class="btn btn-primary" onclick="goStep(5)">Powers &rarr;</button></div>`;
}
function rmEquip(i) { S.equipment.splice(i, 1); render(); }
function addCatalog() {
  const item = S.items.find((it) => it.id === +$('cat-item').value);
  if (item) S.equipment.push({ item_id: item.id, name: item.name, qty: Math.max(1, +$('cat-qty').value || 1), source: 'catalog' });
  render();
}
function addCustom() {
  const name = $('cust-name').value.trim();
  if (!name) return;
  S.equipment.push({ custom_name: name, notes: $('cust-notes').value.trim() || undefined, qty: Math.max(1, +$('cust-qty').value || 1), source: 'custom' });
  render();
}

// Step 5 — powers (magic / psionics guided picker)
// Psionic starting-count house rule (class frontmatter can override with
// psionics.powers_starting / psionics.categories_allowed — no schema change):
// minor = 2 powers, major = 6, master = 8; Super category is master-only.
const PSI_DEFAULT_COUNTS = { minor: 2, major: 6, master: 8 };
function psiConfig(cls) {
  const p = cls.psionics;
  if (!p) return null;
  return {
    count: p.powers_starting ?? PSI_DEFAULT_COUNTS[p.type] ?? 2,
    cats: p.categories_allowed ??
      (p.type === 'master' ? ['Healing', 'Physical', 'Sensitive', 'Super'] : ['Healing', 'Physical', 'Sensitive']),
  };
}
function renderPowers() {
  const magic = S.cls.magic || null;
  const psi = psiConfig(S.cls);
  let inner = '';
  if (!magic && !psi) {
    inner = `<p class="muted">This class has no spellcasting or psionics — carry on.</p>`;
  }
  if (magic) {
    const count = magic.spells_starting || 0;
    const levels = Array.isArray(magic.spell_levels_allowed) ? magic.spell_levels_allowed : null;
    const list = S.spellCatalog.filter((sp) => !levels || levels.includes(sp.level));
    inner += `<h3>Spells — ${S.spells.length}/${count}
      <span class="muted small">(${esc(magic.type)} magic${levels ? ' · levels ' + levels.join(', ') : ''})</span></h3>` +
      list.map((sp) => {
        const on = S.spells.includes(sp.name);
        const blocked = !on && S.spells.length >= count;
        return `<label class="chkrow" style="${blocked ? 'opacity:0.45' : 'cursor:pointer'}">
          <input type="checkbox" ${on ? 'checked' : ''} ${blocked ? 'disabled' : ''}
            data-act="power" data-kind="spell" data-name="${esc(sp.name)}">
          <span>${esc(sp.name)}</span><span class="pct">L${sp.level} · ${sp.ppe} P.P.E.</span></label>`;
      }).join('');
  }
  if (psi) {
    const tier = S.cls.psionics.type;
    const inCategory = S.psiCatalog.filter((p) => psi.cats.includes(p.category));
    // Two gates, and they are not the same. The category gate has always been
    // here (Super is master-only). This is the per-power one: a book can state
    // that an individual power needs a higher tier than its category implies.
    const list = inCategory.filter((p) => derive.meetsTier(tier, p.min_tier));
    const gated = inCategory.length - list.length;

    inner += `<h3>Psionic powers — ${S.psi.length}/${psi.count}
      <span class="muted small">(${esc(tier)} psychic · ${psi.cats.join(', ')})</span></h3>` +
      // Say that something is being withheld, so a short list reads as a rule
      // rather than as a gap in the catalog.
      (gated ? `<p class="attr-note">${gated} more ${gated === 1 ? 'power needs' : 'powers need'} a higher psychic tier than ${esc(tier)}.</p>` : '') +
      list.map((p) => {
        const on = S.psi.includes(p.name);
        const blocked = !on && S.psi.length >= psi.count;
        return `<label class="chkrow" style="${blocked ? 'opacity:0.45' : 'cursor:pointer'}">
          <input type="checkbox" ${on ? 'checked' : ''} ${blocked ? 'disabled' : ''}
            data-act="power" data-kind="psi" data-name="${esc(p.name)}">
          <span>${esc(p.name)}</span><span class="pct">${p.category} · ${p.isp} I.S.P.</span></label>`;
      }).join('');
  }
  $('app').innerHTML = `
  <div class="panel">
    <h2>Magic &amp; Psionics <span class="muted small">— ${esc(S.cls.name)}</span></h2>
    ${inner}
  </div>
  <div class="nav"><button class="btn btn-ghost" onclick="goStep(4)">&larr; Back</button>
  <button class="btn btn-primary" onclick="goStep(6)">Details &rarr;</button></div>`;
}

// Step 6 — bio details. Optional; the derived percentages come straight from
// the attribute tables and are shown so the numbers are not a surprise later.
function renderDetails() {
  const d = derive.bio(S.attrs);
  $('app').innerHTML = `
  <div class="panel">
    <h2>Details <span class="muted small">— ${esc(S.cls.name)}</span></h2>
    <p class="muted">All optional — the identity block from the printed sheet. Anything left blank
      can be filled in later on the character sheet.</p>
    <div class="cols" style="margin-top:12px">
      <div>${BIO_FIELDS.slice(0, 6).map(bioInput).join('')}</div>
      <div>${BIO_FIELDS.slice(6).map(bioInput).join('')}</div>
    </div>
    <h3>Derived from attributes</h3>
    <p class="small">Invoke Trust/Intimidate <b>${d.invoke_trust_pct}%</b> (M.A. ${S.attrs.MA ?? '—'})
      &nbsp;·&nbsp; Charm/Impress <b>${d.charm_impress_pct}%</b> (P.B. ${S.attrs.PB ?? '—'})</p>
    <p class="muted small">Combat bonuses and saving throws are derived the same way and appear on the
      sheet, where any of them can be overridden.</p>
  </div>
  <div class="nav"><button class="btn btn-ghost" onclick="goStep(5)">&larr; Back</button>
  <button class="btn btn-primary" onclick="goStep(7)">Review &rarr;</button></div>`;
}

function bioInput([key, label]) {
  return `<div class="rowline">
    <label class="small" style="min-width:132px">${label}</label>
    <input type="text" value="${esc(S.bio[key] ?? '')}" onchange="setBio('${key}', this.value)" style="flex:1">
  </div>`;
}
function setBio(key, value) {
  const v = String(value).trim();
  if (v) S.bio[key] = v; else delete S.bio[key];
}
function togglePower(kind, name) {
  const list = kind === 'spell' ? S.spells : S.psi;
  const i = list.indexOf(name);
  if (i >= 0) list.splice(i, 1); else list.push(name);
  render();
}
function powersPayload() {
  return [
    ...S.spells.map((n) => {
      const sp = S.spellCatalog.find((x) => x.name === n);
      return { type: 'spell', name: n, level: sp?.level, cost: sp?.ppe };
    }),
    ...S.psi.map((n) => {
      const p = S.psiCatalog.find((x) => x.name === n);
      return { type: 'psionic', name: n, category: p?.category, cost: p?.isp };
    }),
  ];
}

// Step 6 — review & save
function skillsPayload() {
  const find = (n) => skillByName().get(n) || {};
  const occ = S.cls.skills?.occ_skills || [];
  // Choice-group picks are stored exactly like fixed class skills, inheriting
  // the group's base/per_level.
  const groupPicks = occ.flatMap((s, gi) => !isGroup(s) ? [] :
    (S.groupPicks[gi] || []).map((name) => {
      const r = resolveSkill(name, s);
      return { name, category: 'Class', pct: r.base, per_level: r.per_level, type: 'occ' };
    }));
  return [
    ...occ.filter((s) => !isGroup(s)).map((s) => {
      const r = resolveSkill(s.name, s);
      return { name: s.name, category: 'Class', pct: r.base, per_level: r.per_level, type: 'occ' };
    }),
    ...groupPicks,
    ...S.related.map((n) => ({ name: n, category: find(n).category, pct: find(n).base || 0, per_level: find(n).per_level || 0, type: 'related' })),
    ...S.secondary.map((n) => ({ name: n, category: find(n).category, pct: find(n).base || 0, per_level: 0, type: 'secondary' })),
  ];
}
function renderReview() {
  if (!S.pools) computePools();
  const p = S.pools;
  const campaigns = S.campaigns.filter((c) => c.system === S.system);
  const stat = (label, v) => v != null ? `<span class="statline">${label}: <b>${v}</b></span>` : '';
  $('app').innerHTML = `
  <div class="panel">
    <h2>Review &amp; save</h2>
    <div class="rowline"><label class="small">Character name:</label>
      <input type="text" id="char-name" value="${esc(S.charName)}" placeholder="e.g. Sir Roderick" onchange="S.charName=this.value.trim()"></div>
    <div class="rowline"><label class="small">Campaign:</label>
      <select id="campaign-sel" onchange="S.campaignId=+this.value||null">
        <option value="">— pick —</option>
        ${campaigns.map((c) => `<option value="${c.id}" ${S.campaignId === c.id ? 'selected' : ''}>${esc(c.name)} (GM: ${esc(c.gm_email)})</option>`).join('')}
      </select>
      <span class="muted small">or new:</span>
      <input type="text" id="new-campaign" value="${esc(S.newCampaign)}" placeholder="New campaign name" onchange="S.newCampaign=this.value.trim()">
    </div>

    <h3>${esc(S.cls.name)} <span class="muted small">(${esc(S.system)} · ${esc(S.cls.category)})</span> — Level 1, 0 XP</h3>
    <div>${ATTRS.map((a) => `<span class="statline">${a}: <b>${S.attrs[a]}</b></span>`).join('')}</div>
    <h3>Pools <button class="btn btn-sm btn-ghost" onclick="computePools(); render()">↻ reroll</button></h3>
    <div>${stat('H.P.', p.hp)}${stat('S.D.C.', p.sdc)}${stat('M.D.C.', p.mdc)}${stat('P.P.E.', p.ppe)}${stat('I.S.P.', p.isp)}</div>
    <p class="muted small">Rolled from the class formulas (${esc(S.cls.hit_points_base || S.cls.mdc_base || '')}…). Reroll if your GM lets you.</p>

    <h3>Skills (${skillsPayload().length})</h3>
    <p class="small">${skillsPayload().map((s) => esc(s.name) + (s.pct ? ` ${s.pct}%` : '')).join(' · ')}</p>
    <h3>Equipment (${S.equipment.length})</h3>
    <p class="small">${S.equipment.map((e) => esc(e.name || e.custom_name) + (e.qty > 1 ? ` ×${e.qty}` : '')).join(' · ') || '—'}</p>

    ${powersPayload().length ? `<h3>Powers (${powersPayload().length})</h3>
      <p class="small">${powersPayload().map((p) =>
        esc(p.name) + ` <span class="muted">(${p.type === 'spell' ? 'L' + p.level + ' · ' + p.cost + ' P.P.E.' : esc(p.category) + ' · ' + p.cost + ' I.S.P.'})</span>`
      ).join(' · ')}</p>` : ''}
    <p class="warn" id="save-msg"></p>
  </div>
  <div class="nav"><button class="btn btn-ghost" onclick="goStep(6)">&larr; Back</button>
  <button class="btn btn-primary" ${S.saving ? 'disabled' : ''} onclick="save()">💾 Save character</button></div>`;
}
async function save() {
  S.charName = $('char-name').value.trim();
  S.newCampaign = $('new-campaign').value.trim();
  const msg = $('save-msg');
  if (!S.charName) { msg.textContent = 'Give your character a name.'; return; }
  if (!S.campaignId && !S.newCampaign) { msg.textContent = 'Pick a campaign or name a new one.'; return; }
  S.saving = true; msg.textContent = 'Saving…';
  try {
    let campaignId = S.campaignId;
    if (!campaignId) {
      const created = await api('campaigns', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ name: S.newCampaign, system: S.system }) });
      campaignId = created.campaign.id;
    }
    const body = {
      campaign_id: campaignId, name: S.charName, class_id: S.cls.id,
      attributes: S.attrs, skills: skillsPayload(), powers: powersPayload(), pools: S.pools,
      bio: S.bio,
      items: S.equipment.map((e) => ({ item_id: e.item_id, custom_name: e.custom_name, qty: e.qty, notes: e.notes })),
    };
    const res = await api('characters', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });
    S.savedId = res.id;
    render();
  } catch (err) {
    msg.textContent = 'Save failed: ' + err.message;
  } finally {
    S.saving = false;
  }
}

// Saved confirmation view — the full editable sheet lives in sheet.html
async function renderSaved() {
  $('app').innerHTML = '<p class="muted">Loading saved character…</p>';
  try {
    const { character: c, items } = await api('characters/' + S.savedId);
    const attrs = c.attributes || {};
    const stat = (label, v) => v != null ? `<span class="statline">${label}: <b>${v}</b></span>` : '';
    const byType = (t) => (c.skills || []).filter((s) => s.type === t);
    const skillLine = (list) => list.map((s) => esc(s.name) + (s.pct ? ` ${s.pct}%` : '')).join(' · ') || '—';
    $('app').innerHTML = `
    <div class="panel">
      <h2>✅ ${esc(c.name)} <span class="muted small">saved — #${c.id}</span></h2>
      <p class="muted">${esc(c.class_id)} · Level ${c.level} · ${c.xp} XP · Campaign: ${esc(c.campaign_name)} (${esc(c.campaign_system)}) · Player: ${esc(c.player_email)}</p>
      <h3>Attributes</h3>
      <div>${ATTRS.map((a) => stat(a, attrs[a])).join('')}</div>
      <h3>Pools</h3>
      <div>${stat('H.P.', c.hp_current)}${stat('S.D.C.', c.sdc_current)}${stat('M.D.C.', c.mdc_current)}${stat('P.P.E.', c.ppe_current)}${stat('I.S.P.', c.isp_current)}</div>
      <h3>Skills</h3>
      <p class="small"><b>Class:</b> ${skillLine(byType('occ'))}</p>
      <p class="small"><b>Related:</b> ${skillLine(byType('related'))}</p>
      <p class="small"><b>Secondary:</b> ${skillLine(byType('secondary'))}</p>
      ${(c.powers || []).length ? `<h3>Powers</h3><p class="small">${c.powers.map((p) => esc(p.name) + ' <span class="muted">(' + esc(p.type) + ')</span>').join(' · ')}</p>` : ''}
      <h3>Inventory</h3>
      <p class="small">${items.map((it) => esc(it.item_name || it.custom_name) + (it.qty > 1 ? ` ×${it.qty}` : '')).join(' · ') || '—'}</p>
    </div>
    <div class="nav">
      <a class="btn btn-primary" href="sheet.html?id=${c.id}">📜 Open full sheet</a>
      <button class="btn" onclick="startOver()">+ Create another character</button>
    </div>`;
  } catch (err) {
    $('app').innerHTML = `<div class="panel"><p class="err">Failed to load: ${esc(err.message)}</p></div>`;
  }
}
function startOver() {
  S.savedId = null; S.step = 0; S.cls = null; S.charName = ''; S.campaignId = null; S.newCampaign = '';
  resetBuild(); boot(false); render();
}

// ---------- boot ----------
async function boot(first = true) {
  try {
    // Everything comes from the database now — classes, catalogs, and items —
    // so content changes take effect without a redeploy.
    const [classesRes, catalogsRes, itemsRes, campaignsRes, charsRes, meRes] = await Promise.all([
      api('classes'),
      api('catalogs'),
      api('items'),
      api('campaigns'),
      api('characters'),
      api('me').catch(() => ({})),
    ]);
    S.classes = classesRes.classes;
    S.skillCatalog = catalogsRes.skills;
    _skillIndex = null;
    S.spellCatalog = catalogsRes.spells;
    S.psiCatalog = catalogsRes.psionics;
    S.items = itemsRes.items;
    S.campaigns = campaignsRes.campaigns;
    S.existing = charsRes.characters;
    S.me = meRes.email ?? null;
    S.isAdmin = !!meRes.is_admin;
    if (classesRes.failures?.length) console.error('Class parse failures:', classesRes.failures);
    if (first) render();
  } catch (err) {
    $('app').innerHTML = `<div class="panel"><p class="err">Failed to load app data: ${esc(err.message)}</p></div>`;
  }
}

// Checkbox toggles carry their value in data- attributes and are dispatched
// here rather than interpolated into an inline handler. Catalog names come from
// sourcebook PDFs and routinely contain apostrophes and quotes, which would
// terminate a JS string literal inside an HTML attribute.
$('app').addEventListener('change', (ev) => {
  const el = ev.target;
  switch (el.dataset?.act) {
    case 'skill': return toggleSkill(el.dataset.kind, el.dataset.name);
    case 'group': return toggleGroupPick(+el.dataset.group, el.dataset.name, +el.dataset.limit);
    case 'power': return togglePower(el.dataset.kind, el.dataset.name);
  }
});

// Inline onclick handlers live in the global scope; this module does not, so
// every entry point the generated markup references is exposed explicitly.
Object.assign(window, {
  S, render, computePools, goStep, pickSystem, classMode, quizPick, pickClass,
  confirmClass, setMethod, setAllMethod, doRoll, rollAll, manualSet, pbAdj,
  toggleSkill, toggleGroupPick, rmEquip, addCatalog, addCustom, togglePower, setBio, save, startOver,
});

boot();
