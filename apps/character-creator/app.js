// Character creation wizard: system → class → attributes → skills →
// equipment → powers → review/save.
//
// ES module so it can share js/dice.js with the server-side leveling code
// (functions/api/character-creator/_lib/leveling.js imports the same file).
// /shared/js/ui.js loads first as a classic script, so escHtml() is global;
// inline onclick handlers need their entry points on window — see the
// Object.assign at the bottom.
import { d, evalDice, rollPoolFormula } from './js/dice.js';
import { isChoiceGroup, isGearChoice, applyVariant, combineClasses } from './js/parser.js';

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
  // An unfinished build found on the server, awaiting resume-or-discard.
  draftOffer: null,
  classes: [], cls: null,
  attrMethods: {}, attrs: {},
  related: [], secondary: [], groupPicks: {},
  // Starting-gear choices the class leaves open, and the slugs picked for each,
  // keyed by the entry's index in equipment_starting.
  gearChoices: [], gearPicks: {},
  // Which stage of the class, for classes that come in stages (a Dragon
  // hatchling vs an adult). NULL for every class that has none.
  variant: null,
  // The O.C.C. taken alongside an R.C.C., and its own stage. A racial class
  // grants no related or secondary skills — those come from the occupation —
  // so an R.C.C. character without one is deliberately thin.
  occ: null, occVariant: null,
  equipment: [], equipInit: false,
  charName: '', campaignId: null, newCampaign: '',
  spells: [], psi: [], bio: {},
  pools: null, savedId: null, saving: false,
  skillCatalog: [], items: [], campaigns: [], existing: [],
  // Retired gear slugs → the slug they resolve to now. See findItem().
  itemRedirects: {},
  spellCatalog: [], psiCatalog: [], me: null, isAdmin: false,
  // Picker filter text. Transient view state, never persisted in a draft —
  // resuming a build should not resume half a search.
  gearFilter: '', relatedFilter: '', secondaryFilter: '', spellFilter: '', psiFilter: '',
};

const $ = (id) => document.getElementById(id);
const esc = escHtml; // from /shared/js/ui.js

// api() and errorDetails() come from js/api.js, loaded first as a classic script.

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
function computePools() {
  const c = S.cls;
  S.pools = {
    hp: rollPoolFormula(c.hit_points_base, S.attrs),
    sdc: rollPoolFormula(c.sdc_base, S.attrs),
    mdc: rollPoolFormula(c.mdc_base, S.attrs),
    ppe: rollPoolFormula(c.ppe_base, S.attrs),
    isp: c.psionics ? rollPoolFormula(c.psionics.isp_base, S.attrs) : null,
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

// ---------- draft persistence ----------
// Eight steps, and step 3 ROLLS. A refresh or a closed tab used to lose all of
// it, and a roll is the one thing you cannot honestly redo — you either accept
// different numbers or re-roll until you like them.
//
// An explicit allowlist, not a copy of S: the state also holds the class,
// skill, spell and gear catalogs, which are large, shared, and stale the moment
// they are written down. Everything here is the build itself.
const DRAFT_KEYS = [
  'step', 'system', 'classMode', 'quiz', 'variant', 'occ', 'occVariant', 'attrMethods', 'attrs',
  'related', 'secondary', 'groupPicks', 'gearPicks',
  'equipment', 'equipInit', 'charName', 'campaignId', 'newCampaign',
  'spells', 'psi', 'bio', 'pools',
];

let draftTimer = null;

// Nothing is worth saving until a class is picked — before that a "draft" is a
// radio button, and offering to resume one would be noise.
function draftWorthSaving() {
  return !!S.cls && !S.savedId && !S.draftOffer;
}

// The class is stored as an ID and re-resolved on restore, so a draft never
// carries a stale copy of a class definition that has since been edited.
function draftPayload() {
  const state = {};
  for (const k of DRAFT_KEYS) state[k] = S[k];
  return {
    state,
    step: S.step,
    system: S.system,
    class_id: S.cls?.id ?? null,
    class_name: S.cls?.name ?? null,
    char_name: S.charName || null,
  };
}

// Debounced from render(), which already runs after every mutation — one hook
// instead of remembering to call this from thirty handlers.
function queueDraftSave() {
  if (!draftWorthSaving()) return;
  clearTimeout(draftTimer);
  draftTimer = setTimeout(saveDraft, 1500);
}

async function saveDraft() {
  if (!draftWorthSaving()) return;
  try {
    await api('draft', {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(draftPayload()),
    });
  } catch {
    // A draft is a convenience. Failing to store one must never interrupt or
    // even interject in the build it is trying to protect.
  }
}

async function discardDraft() {
  clearTimeout(draftTimer);
  try { await api('draft', { method: 'DELETE' }); } catch { /* see above */ }
}

function resumeDraft() {
  const d = S.draftOffer;
  S.draftOffer = null;
  Object.assign(S, d.state);
  // The draft stores the class id and the stage separately, so the class is
  // resolved from scratch here — an edited class definition takes effect, and
  // the variant is re-applied on top of it.
  S.cls = combineClasses(
    applyVariant(S.classes.find((c) => c.id === d.class_id) || null, S.variant),
    S.occ ? applyVariant(S.classes.find((c) => c.id === S.occ), S.occVariant) : null);
  S.savedId = null;
  render();
}

async function dismissDraft() {
  S.draftOffer = null;
  await discardDraft();
  render();
}

// Shown before the wizard rather than over it: resuming into step 4 of someone
// else's half-finished build with no explanation is worse than the data loss
// this feature exists to prevent.
function renderDraftOffer() {
  const d = S.draftOffer;
  const when = d.updated_at ? d.updated_at.replace('T', ' ').replace('Z', '') : 'earlier';
  $('app').innerHTML = `
  <div class="panel">
    <h2>You have an unfinished character</h2>
    <p>${esc(d.char_name || 'Unnamed')} — <b>${esc(d.class_name || d.class_id || 'unknown class')}</b>,
       stopped at step ${d.step + 1} of ${STEPS.length} (${esc(STEPS[d.step] || '?')}).</p>
    <p class="muted small">Last saved ${esc(when)} UTC.</p>
    <div class="nav">
      <button class="btn btn-primary" onclick="resumeDraft()">Resume this build</button>
      <button class="btn btn-ghost" onclick="dismissDraft()">Discard and start fresh</button>
    </div>
  </div>`;
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
  if (S.draftOffer) { renderStepper(); return renderDraftOffer(); }
  if (S.savedId) { renderStepper(); return renderSaved(); }
  renderStepper();
  [renderSystem, renderClass, renderAttributes, renderSkills, renderEquipment,
   renderPowers, renderDetails, renderReview][S.step]();
  wirePickers();
  queueDraftSave();
}

// Filter inputs are re-created by every render, so their listeners are re-bound
// here rather than delegated — the input needs its caret restored mid-keystroke,
// which Picker.wire handles and a delegated listener could not.
function wirePickers() {
  const only = (rows) => (rows.length === 1 ? rows[0] : null);

  Picker.wire('cat-filter', {
    onInput: (v) => { S.gearFilter = v; render(); },
    lone: only(Picker.filter(S.items, S.gearFilter)),
    onEnter: (item) => {
      S.equipment.push({ item_id: item.id, name: item.name, qty: 1, source: 'catalog' });
      S.gearFilter = '';
      render();
    },
  });

  for (const [id, key] of [['related-filter', 'relatedFilter'], ['secondary-filter', 'secondaryFilter'],
    ['spell-filter', 'spellFilter'], ['psi-filter', 'psiFilter']]) {
    Picker.wire(id, { onInput: (v) => { S[key] = v; render(); } });
  }
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
  S.gearChoices = []; S.gearPicks = {};
  S.variant = null;
  S.occ = null; S.occVariant = null;
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
    ${variantPicker()}
    ${occPicker()}
  </div>
  <div class="nav"><button class="btn btn-ghost" onclick="goStep(0)">&larr; Back</button>
  <button class="btn btn-primary" ${canUseClass() ? '' : 'disabled'} onclick="confirmClass()">Use this class &rarr;</button></div>`;
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
// A class with variants is not usable until one is chosen — a Dragon is always
// some particular age, and defaulting to the first stage would pick for you.
function canUseClass() {
  if (!S.cls) return false;
  return !(S.cls.variants || []).length || !!S.variant;
}

// Which stage of the class. Shown only when the class has stages, so every
// other class is unaffected.
function variantPicker() {
  const variants = S.cls?.variants || [];
  if (!variants.length) return '';
  return `<div class="panel-inset">
    <h3>Which ${esc(S.cls.name)}?</h3>
    <p class="muted small">These share their skills, abilities and lore, and differ in their
      attribute dice, pools and what the class grants.</p>
    ${variants.map((v) => {
      const on = S.variant === v.id;
      const bits = [
        v.mdc_base ? `M.D.C. ${esc(v.mdc_base)}` : '',
        v.hit_points_base ? `H.P. ${esc(v.hit_points_base)}` : '',
        v.ppe_base ? `P.P.E. ${esc(v.ppe_base)}` : '',
      ].filter(Boolean).join(' · ');
      return `<label class="chkrow" style="cursor:pointer">
        <input type="radio" name="class-variant" ${on ? 'checked' : ''}
          onchange="pickVariant('${esc(v.id)}')">
        <span><b>${esc(v.name || v.id)}</b></span>
        <span class="pct">${bits}</span></label>`;
    }).join('')}
  </div>`;
}

function pickVariant(id) { S.variant = id; render(); }

// An O.C.C. alongside a racial class. Offered only for an R.C.C., because that
// is the pairing the books describe: the race is what you are, the occupation
// is what you trained as, and the related and secondary skill allowances come
// entirely from the latter.
function occPicker() {
  if (S.cls?.category !== 'rcc') return '';
  const options = S.classes.filter((c) => c.system === S.system && c.category === 'occ');
  if (!options.length) return '';
  const chosen = S.occ ? S.classes.find((c) => c.id === S.occ) : null;
  return `<div class="panel-inset">
    <h3>Occupation <span class="muted small">— optional</span></h3>
    <p class="muted small">A racial class grants no related or secondary skills; those come from the
      O.C.C. a character trains in. Leave this blank for a creature that has none.</p>
    <div class="rowline">
      <select onchange="pickOcc(this.value)">
        <option value="">— none —</option>
        ${options.map((c) => `<option value="${esc(c.id)}"${S.occ === c.id ? ' selected' : ''}>${esc(c.name)}</option>`).join('')}
      </select>
    </div>
    ${chosen?.variants?.length ? `<div class="rowline">
      <span class="muted small">Which ${esc(chosen.name)}?</span>
      <select onchange="S.occVariant = this.value || null; render()">
        ${chosen.variants.map((v) => `<option value="${esc(v.id)}"${S.occVariant === v.id ? ' selected' : ''}>${esc(v.name || v.id)}</option>`).join('')}
      </select></div>` : ''}
    ${chosen ? `<p class="small">Related skills: <b>${chosen.skills?.occ_related_skills?.count ?? 0}</b>
      · Secondary: <b>${chosen.skills?.secondary_skills?.count ?? 0}</b></p>` : ''}
  </div>`;
}

function pickOcc(id) {
  S.occ = id || null;
  // A different occupation cannot keep the previous one's stage.
  S.occVariant = null;
  const chosen = S.occ ? S.classes.find((c) => c.id === S.occ) : null;
  if (chosen?.variants?.length) S.occVariant = chosen.variants[0].id;
  render();
}

function confirmClass() {
  // The class the rest of the wizard sees is the resolved one — its attribute
  // dice, pools and bonuses are the variant's. Picking a different class puts
  // the base back, so this never compounds.
  // What the rest of the wizard sees is ONE class: the variant resolved, and
  // the occupation composed in. Nothing downstream has to know there were two.
  const rcc = applyVariant(S.cls, S.variant);
  const occ = S.occ ? applyVariant(S.classes.find((c) => c.id === S.occ), S.occVariant) : null;
  S.cls = combineClasses(rcc, occ);
  S.step = 2;
  render();
}

// Step 2 — attributes
function renderAttributes() {
  const classBonus = derive.classBonuses(S.cls, 1);
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
    // A class bonus is shown here but never rolled into the stored value — what
    // gets saved is what was rolled, and the bonus is added wherever the number
    // is actually used.
    const add = classBonus.attributes[a];
    const boost = add && v != null
      ? ` <span class="attr-note ok">${add > 0 ? '+' : ''}${add} from ${esc(S.cls.name)} = ${v + add}</span>` : '';
    return `<tr><td><b>${a}</b></td>
      <td><select onchange="setMethod('${a}', this.value)">
        <option value="roll" ${m === 'roll' ? 'selected' : ''}>Random roll</option>
        <option value="point" ${m === 'point' ? 'selected' : ''}>Point-buy</option>
        <option value="manual" ${m === 'manual' ? 'selected' : ''}>Manual entry</option>
      </select></td>
      <td>${control}</td><td>${req}${boost}${dice ? ` <span class="attr-note">racial dice: ${esc(dice)}</span>` : ''}</td></tr>`;
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
// A catalog row belongs to this build's system, or to no system at all.
// NULL/blank means unrestricted, which is how skills.systems has always read and
// is now how spells, psionics and gear read too. A Palladium Fantasy spell
// chapter must not offer its spells to a Rifts mage.
function inSystem(row) {
  const sys = row?.system;
  return !sys || sys === 'both' || sys === S.system;
}

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

    // A category group offers the whole category, which includes skills this
    // very class already grants outright — the Chiang-Ku grants Advanced Math
    // and Art as fixed skills and then offers Science and Technical. Picking
    // one listed the skill twice and the save was refused with a duplicate.
    //
    // Anything already held is dropped from the options rather than shown
    // disabled: it is not a choice you might make, it is one you already have.
    // Everything the character already has by any route: the class's fixed
    // skills, picks made in OTHER choice groups, and the related and secondary
    // skills chosen on this same step. takenNames() is exactly that set, minus
    // this group's own picks — which must stay selectable so they can be
    // unticked.
    const mine = new Set((S.groupPicks[gi] || []).map((n) => String(n).toLowerCase()));
    const alreadyHeld = new Set([...takenNames()].filter((n) => !mine.has(n)));
    const opts = optionNames.filter((name) => name && !alreadyHeld.has(String(name).toLowerCase())).map((name) => {
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

  // The category gate already narrows these, which is why 128 skills has been
  // survivable — but "Any category" on the secondary list is the whole catalog,
  // and a checkbox list you have to scroll to search is not a search.
  // A ticked skill always stays visible, or filtering would appear to un-pick it.
  const pickList = (catalog, chosen, kind, limit, query) => {
    const shown = Picker.filter(catalog, query)
      .concat(catalog.filter((s) => chosen.includes(s.name) && !Picker.match(s, query)));
    if (!shown.length) return '<p class="muted small">Nothing matches that filter.</p>';
    return shown.map((s) => {
      const on = chosen.includes(s.name);
      const blocked = !on && (taken.has(s.name.toLowerCase()) || chosen.length >= limit);
      return `<label class="chkrow" style="${blocked ? 'opacity:0.45' : 'cursor:pointer'}">
        <input type="checkbox" ${on ? 'checked' : ''} ${blocked ? 'disabled' : ''}
          data-act="skill" data-kind="${kind}" data-name="${esc(s.name)}">
        <span>${esc(s.name)}</span>
        <span class="pct">${s.category} · ${s.base ? s.base + '%' + (s.per_level ? ' +' + s.per_level + '/lvl' : '') : '—'}</span>
      </label>`;
    }).join('');
  };

  const relatedPool = catalogFor(relatedCfg.categories);
  const secondaryPool = catalogFor(null);

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
        ${Picker.inputHtml({ id: 'related-filter', value: S.relatedFilter,
          placeholder: 'Filter…', shown: Picker.filter(relatedPool, S.relatedFilter).length,
          total: relatedPool.length })}
        ${pickList(relatedPool, S.related, 'related', relatedCfg.count, S.relatedFilter)}
      </div>
      <div>
        <h3>Secondary skills — ${S.secondary.length}/${secondaryCfg.count}</h3>
        <p class="muted small">Any category, base % only.</p>
        ${Picker.inputHtml({ id: 'secondary-filter', value: S.secondaryFilter,
          placeholder: 'Filter…', shown: Picker.filter(secondaryPool, S.secondaryFilter).length,
          total: secondaryPool.length })}
        ${pickList(secondaryPool, S.secondary, 'secondary', secondaryCfg.count, S.secondaryFilter)}
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

// Class markdown cites gear by slug, and a slug can be retired by a catalog
// merge or a rename without the markdown ever being touched. Falling through to
// the redirect is what keeps that class's starting gear resolving to a real
// item instead of degrading to a bare text line with no stats.
function findItem(slug) {
  if (!slug) return null;
  const direct = S.items.find((it) => it.slug === slug);
  if (direct) return direct;
  const to = S.itemRedirects[String(slug).toLowerCase()];
  return to ? S.items.find((it) => it.slug === to) : null;
}

// A class's starting gear is a mix of fixed items and "one energy pistol of
// choice" groups. Fixed entries land in the inventory immediately; the choices
// are held aside until the player resolves them, because picking for them would
// be inventing a decision the book left open.
function initEquipment() {
  const starting = S.cls.equipment_starting || [];

  // The choices are re-derived every time, not guarded by equipInit. A restored
  // draft brings back which options were TICKED but not what the options were,
  // so deriving them once and skipping thereafter would leave the picks with
  // nothing to render against.
  S.gearChoices = starting.flatMap((eq, gi) => !isGearChoice(eq) ? [] : [{
    gi,
    choose: eq.choose,
    qty: eq.qty || 1,
    label: eq.label || '',
    options: (eq.from || []).map((slug) => ({ slug, item: findItem(slug) })),
  }]);

  // The inventory itself is guarded, because it is editable — re-deriving it
  // would undo every hand-added or removed row.
  if (S.equipInit) return;
  S.equipment = starting.flatMap((eq) => {
    if (isGearChoice(eq)) return [];
    const item = findItem(eq.item_id);
    return [item
      ? { item_id: item.id, name: item.name, qty: eq.qty || 1, source: 'starting' }
      : { custom_name: eq.item_id.replace(/-/g, ' '), qty: eq.qty || 1, source: 'starting', notes: 'starting gear (not in item catalog yet)' }];
  });
  S.equipInit = true;
}

// Every choice resolved? Starting gear is finite and the book intends the
// character to have it, so an unresolved choice is an oversight rather than a
// deliberate omission — the step will not advance until they are all made.
function gearChoicesOutstanding() {
  return S.gearChoices.filter((c) => (S.gearPicks[c.gi] || []).length < c.choose);
}

// What actually gets saved: the fixed starting gear and anything added by hand,
// plus the choices the player resolved. Kept as a function rather than pushed
// into S.equipment so a pick stays reversible — unticking a box must take the
// item back out, and a copy in the inventory list would survive it.
function equipmentPayload() {
  return [...S.equipment, ...pickedGear()];
}

// Resolved picks, folded into the inventory shape the save endpoint expects.
function pickedGear() {
  const out = [];
  for (const c of S.gearChoices) {
    for (const slug of S.gearPicks[c.gi] || []) {
      const item = findItem(slug);
      out.push(item
        ? { item_id: item.id, name: item.name, qty: c.qty, source: 'starting' }
        : { custom_name: slug.replace(/-/g, ' '), qty: c.qty, source: 'starting', notes: 'chosen starting gear (not in item catalog yet)' });
    }
  }
  return out;
}

function toggleGearPick(gi, slug, limit) {
  const picked = S.gearPicks[gi] || (S.gearPicks[gi] = []);
  const at = picked.indexOf(slug);
  if (at >= 0) picked.splice(at, 1);
  else if (picked.length < limit) picked.push(slug);
  render();
}
function renderEquipment() {
  initEquipment();
  const rows = S.equipment.map((e, i) =>
    `<tr><td>${esc(e.name || e.custom_name)}</td><td>×${e.qty}</td>
     <td><span class="tag">${e.source}</span></td><td class="muted small">${esc(e.notes || '')}</td>
     <td><button class="btn btn-sm btn-ghost" onclick="rmEquip(${i})">✕</button></td></tr>`).join('');
  // Filtered rather than dumped: the gear catalog is 74 rows and grows with
  // every book imported, and picking one item out of a native dropdown that
  // long means scrolling past everything you did not want.
  const gearMatches = Picker.filter(S.items, S.gearFilter);
  const catalogOpts = gearMatches.map((it) => `<option value="${it.id}">${esc(it.name)}</option>`).join('');

  // "One energy pistol of choice" — the book leaves it open, so the player
  // closes it here. Same shape as the skill choice-groups on step 3.
  const choiceBlocks = S.gearChoices.map((c) => {
    const picked = S.gearPicks[c.gi] || [];
    const opts = c.options.map((o) => {
      const on = picked.includes(o.slug);
      const blocked = !on && picked.length >= c.choose;
      const detail = o.item
        ? [o.item.category, o.item.weight_lbs ? `${o.item.weight_lbs} lb` : '', o.item.cost ? `${o.item.cost}` : '']
          .filter(Boolean).join(' · ')
        : 'not in the catalog yet';
      return `<label class="chkrow" style="${blocked ? 'opacity:0.45' : 'cursor:pointer'}; margin-left:18px">
        <input type="checkbox" ${on ? 'checked' : ''} ${blocked ? 'disabled' : ''}
          data-act="gear" data-group="${c.gi}" data-limit="${c.choose}" data-slug="${esc(o.slug)}">
        <span>${esc(o.item ? o.item.name : o.slug.replace(/-/g, ' '))}</span>
        <span class="pct">${esc(detail)}</span></label>`;
    }).join('');
    return `<div class="chkrow"><b>Pick ${c.choose}${c.label ? ` — ${esc(c.label)}` : ''}</b>
      <span class="pct">${picked.length}/${c.choose} chosen</span></div>${opts}`;
  }).join('');

  const outstanding = gearChoicesOutstanding().length;

  $('app').innerHTML = `
  <div class="panel">
    <h2>Equipment <span class="muted small">— ${esc(S.cls.name)}</span></h2>
    <table>${rows || '<tr><td class="muted">Nothing yet.</td></tr>'}</table>
    ${choiceBlocks ? `<h3>Choose your starting gear</h3>
      <p class="muted small">Your class leaves these open.</p>${choiceBlocks}` : ''}
    <h3>Add from item catalog</h3>
    ${S.items.length ? `
      ${Picker.inputHtml({ id: 'cat-filter', value: S.gearFilter,
        placeholder: 'Filter gear by name, category or book…',
        shown: gearMatches.length, total: S.items.length })}
      <div class="rowline">
        <select id="cat-item" size="1">${catalogOpts || '<option value="">— no match —</option>'}</select>
        <input type="number" id="cat-qty" value="1" min="1">
        <button class="btn btn-sm" ${gearMatches.length ? '' : 'disabled'} onclick="addCatalog()">Add</button>
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
  <button class="btn btn-primary" ${outstanding ? 'disabled' : ''} onclick="goStep(5)">Powers &rarr;</button>
  ${outstanding ? `<span class="muted small">${outstanding} gear choice${outstanding === 1 ? '' : 's'} still to make.</span>` : ''}</div>`;
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
    const pool = S.spellCatalog.filter((sp) => inSystem(sp) && (!levels || levels.includes(sp.level)));
    // A chosen spell stays visible whatever the filter says, or narrowing the
    // list would look like it had un-picked something.
    const list = Picker.filter(pool, S.spellFilter)
      .concat(pool.filter((sp) => S.spells.includes(sp.name) && !Picker.match(sp, S.spellFilter)));
    inner += `<h3>Spells — ${S.spells.length}/${count}
      <span class="muted small">(${esc(magic.type)} magic${levels ? ' · levels ' + levels.join(', ') : ''})</span></h3>` +
      Picker.inputHtml({ id: 'spell-filter', value: S.spellFilter, placeholder: 'Filter spells…',
        shown: Picker.filter(pool, S.spellFilter).length, total: pool.length }) +
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
    const inCategory = S.psiCatalog.filter((p) => inSystem(p) && psi.cats.includes(p.category));
    // Two gates, and they are not the same. The category gate has always been
    // here (Super is master-only). This is the per-power one: a book can state
    // that an individual power needs a higher tier than its category implies.
    const pool = inCategory.filter((p) => derive.meetsTier(tier, p.min_tier));
    const gated = inCategory.length - pool.length;
    const list = Picker.filter(pool, S.psiFilter)
      .concat(pool.filter((p) => S.psi.includes(p.name) && !Picker.match(p, S.psiFilter)));

    inner += `<h3>Psionic powers — ${S.psi.length}/${psi.count}
      <span class="muted small">(${esc(tier)} psychic · ${psi.cats.join(', ')})</span></h3>` +
      // Say that something is being withheld, so a short list reads as a rule
      // rather than as a gap in the catalog. Counted against the tier-gated
      // pool, not the filtered view — the filter is yours, the gate is not.
      (gated ? `<p class="attr-note">${gated} more ${gated === 1 ? 'power needs' : 'powers need'} a higher psychic tier than ${esc(tier)}.</p>` : '') +
      Picker.inputHtml({ id: 'psi-filter', value: S.psiFilter, placeholder: 'Filter powers…',
        shown: Picker.filter(pool, S.psiFilter).length, total: pool.length }) +
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
  const d = derive.bio(S.attrs, null, derive.classBonuses(S.cls, 1));
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
// ---------- review layout ----------
// The review used to run everything together as one dot-separated paragraph.
// A Chiang-Ku Hatchling arrives with 31 skills, which as prose is unreadable
// and — more to the point — hides the duplicates that make a save fail.

const REVIEW_COLUMN = 15;   // entries per column before a new one starts

function poolRow(label, v) {
  return v == null ? '' : `<div class="stat-row"><span>${label}</span><b>${v}</b></div>`;
}

// A section laid out in columns of REVIEW_COLUMN, so a long list reads down
// rather than wrapping across. Omitted entirely when there is nothing in it —
// a class with no spells should not show an empty Spells heading.
function listSection(title, entries) {
  if (!entries.length) return '';
  const columns = [];
  for (let i = 0; i < entries.length; i += REVIEW_COLUMN) {
    columns.push(entries.slice(i, i + REVIEW_COLUMN));
  }
  return `<h3>${title} <span class="muted small">(${entries.length})</span></h3>
    <div class="review-cols">
      ${columns.map((col) => `<ul class="review-col">${col.map((e) => `<li>${e}</li>`).join('')}</ul>`).join('')}
    </div>`;
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

    <div class="review-stats">
      <div class="stat-col">
        <h4>Attributes</h4>
        ${ATTRS.map((a) => `<div class="stat-row"><span>${a}</span><b>${S.attrs[a] ?? '—'}</b></div>`).join('')}
      </div>
      <div class="stat-col">
        <h4>Pools <button class="btn btn-sm btn-ghost" onclick="computePools(); render()">↻ reroll</button></h4>
        ${poolRow('H.P.', p.hp)}${poolRow('S.D.C.', p.sdc)}${poolRow('M.D.C.', p.mdc)}
        ${poolRow('P.P.E.', p.ppe)}${poolRow('I.S.P.', p.isp)}
        <p class="muted small" style="margin-top:6px">Rolled from the class formulas. Reroll if your GM lets you.</p>
      </div>
    </div>

    ${listSection('Skills', skillsPayload().map((s) => esc(s.name) + (s.pct ? ` <span class="muted">${s.pct}%</span>` : '')))}
    ${listSection('Equipment', equipmentPayload().map((e) => esc(e.name || e.custom_name) + (e.qty > 1 ? ` <span class="muted">×${e.qty}</span>` : '')))}
    ${listSection('Spells', powersPayload().filter((x) => x.type === 'spell')
      .map((x) => esc(x.name) + ` <span class="muted">L${x.level} · ${x.cost} P.P.E.</span>`))}
    ${listSection('Psionic powers', powersPayload().filter((x) => x.type === 'psionic')
      .map((x) => esc(x.name) + ` <span class="muted">${esc(x.category)} · ${x.cost} I.S.P.</span>`))}
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
      class_variant: S.variant || undefined,
      occ_class_id: S.occ || undefined,
      occ_class_variant: S.occVariant || undefined,
      attributes: S.attrs, skills: skillsPayload(), powers: powersPayload(), pools: S.pools,
      bio: S.bio,
      items: equipmentPayload().map((e) => ({ item_id: e.item_id, custom_name: e.custom_name, qty: e.qty, notes: e.notes })),
    };
    const res = await api('characters', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });
    S.savedId = res.id;
    // The build is a real character now; the draft has nothing left to protect.
    await discardDraft();
    render();
  } catch (err) {
    // Say WHICH rule broke. The class rules are enforced server-side, so this
    // is the only place a player finds out what to change.
    const details = errorDetails(err);
    msg.innerHTML = details.length
      ? `Save failed: ${esc(err.message)}<ul class="err-list">`
        + details.map((d) => `<li>${esc(d)}</li>`).join('') + '</ul>'
      : `Save failed: ${esc(err.message)}`;
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
  S.draftOffer = null;
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
    S.itemRedirects = itemsRes.redirects || {};
    S.campaigns = campaignsRes.campaigns;
    S.existing = charsRes.characters;
    S.me = meRes.email ?? null;
    S.isAdmin = !!meRes.is_admin;
    if (classesRes.failures?.length) console.error('Class parse failures:', classesRes.failures);

    // Only offered on a genuine first load. startOver() calls boot(false) after
    // deliberately clearing the build, and re-offering the draft it just
    // finished would be the opposite of helpful.
    if (first) {
      const { draft } = await api('draft').catch(() => ({ draft: null }));
      // A draft naming a class that no longer resolves — retired, renamed,
      // re-imported under a different id — cannot be restored into anything
      // coherent, so it is dropped rather than half-applied.
      if (draft && S.classes.some((c) => c.id === draft.class_id)) S.draftOffer = draft;
      else if (draft) await discardDraft();
    }
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
    case 'gear': return toggleGearPick(+el.dataset.group, el.dataset.slug, +el.dataset.limit);
    case 'power': return togglePower(el.dataset.kind, el.dataset.name);
  }
});

// The draft save is debounced, so the last second or two of work may not have
// reached the server yet. Warn only once attributes are rolled: a roll is the
// first thing that cannot be reproduced, and before that the "loss" is picking
// a system and a class again.
window.addEventListener('beforeunload', (ev) => {
  if (S.savedId || !S.cls || S.draftOffer) return;
  if (!Object.keys(S.attrs || {}).length) return;
  ev.preventDefault();
  ev.returnValue = '';
});

// Inline onclick handlers live in the global scope; this module does not, so
// every entry point the generated markup references is exposed explicitly.
Object.assign(window, {
  S, render, computePools, goStep, pickSystem, classMode, quizPick, pickClass,
  confirmClass, setMethod, setAllMethod, doRoll, rollAll, manualSet, pbAdj,
  toggleSkill, toggleGroupPick, rmEquip, addCatalog, addCustom, togglePower, setBio, save, startOver,
  resumeDraft, dismissDraft, pickVariant, pickOcc,
});

boot();
