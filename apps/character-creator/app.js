// Character creation wizard: system → class → attributes → skills →
// equipment → powers → review/save.
//
// ES module so it can share js/dice.js with the server-side leveling code
// (functions/api/character-creator/_lib/leveling.js imports the same file).
// /shared/js/ui.js loads first as a classic script, so escHtml() is global;
// inline onclick handlers need their entry points on window — see the
// Object.assign at the bottom.
import { evalDice, rollPoolFormula, rollAttribute, rollQuantity } from './js/dice.js';
import { LANGUAGE_OTHER, isLanguageName, languageSkillName } from './js/language-skills.js';
import { rollPsionics, psionicShape, withRolledPsionics, PSIONIC_CATEGORIES, PSIONIC_TIER_RULES,
         rollsForPsionics as classRollsForPsionics } from './js/psionics.js';
import { isChoiceGroup, isGearChoice, applyVariant,
         categoryAllows, categoryLabel, needsOccupation, abilityOccOptions,
         bonusesFromSkills, sumBonusGroups } from './js/parser.js';
import { composeClass } from './js/compose.js';

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
  ['birth_order', 'Birth Order'], ['land_of_origin', 'Land of Origin'],
  ['disposition', 'Disposition'], ['racial_bias', 'Racial Bias'],
  ['money', null],   // label depends on the system — see bioLabel()
];
// Split evenly rather than at a fixed index: the list has grown twice and a
// hard-coded 6 left one column noticeably longer each time.
const BIO_HALF = Math.ceil(BIO_FIELDS.length / 2);

// Gold in Palladium, credits in Rifts. Resolved at render because the system is
// not known when this list is declared.
const bioLabel = ([key, label]) => label ?? (key === 'money' ? rules.currencyLabel(S.system) : key);
// Point-buy (house rule — Palladium has no native point-buy):
// all 8 attributes start at 8; 40-point pool; +1 costs 1 point up to 15,
// 2 points from 16-18 (cap 18, floor 3); lowering below 8 refunds 1/point.
const PB_POOL = 40, PB_BASE = 8, PB_CAP = 18, PB_FLOOR = 3;

const S = {
  step: 0, system: null, classMode: 'browse', quiz: [null, null, null],
  // An unfinished build found on the server, awaiting resume-or-discard.
  draftOffer: null,
  classes: [], cls: null,
  attrMethods: {}, attrs: {}, attrRolls: {},
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
  // Step 3. psiRoll is {roll, tier} once rolled — null means not yet rolled,
  // and a tier of null is a real result (26-00, no psionics) rather than an
  // absence, so the two must stay distinguishable.
  psiRoll: null, psiShape: null, psiCategory: null, psiTrimmed: 0,
  // The Age table's ×2 for long-lived races, and the percentile each field
  // last rolled — shown so a result can be checked against the book.
  longLived: false, bioRolls: {},
  // A class may state an attribute bonus as dice ("add 2D6 to P.S."). Rolled
  // once here and stored, because it cannot be re-evaluated on every render.
  attrBonuses: {},
  // What a class's DICE combat/save bonuses came up. Rolled once, like
  // attrBonuses, because both are read at render time.
  rolledBonuses: { combat: {}, saves: {} },
  // Abilities picked from a class's choice group. A LIST, not a set: some are
  // repeatable and the second take means something different.
  abilities: [],
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
// The exceptional-roll rule lives in dice.js, so a class that spells out its
// own `3d6` behaves identically to one that says nothing. It used to not:
// stating the dice took a different branch that skipped the bonus die entirely,
// and the same 3d6 produced different characters depending on how the class
// happened to be written.
//
// The roll is kept whole, not flattened to a number, so the step can show how
// an exceptional total was reached.
function rollAttr(attr) {
  return rollAttribute(S.cls?.attribute_dice?.[attr] || '3d6');
}
function setRoll(a) {
  const r = rollAttr(a);
  S.attrs[a] = r.total;
  S.attrRolls[a] = r.exceptional.length ? r : null;
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

// A class may state an attribute bonus as dice — "add 2D6 to P.S." Rolled once
// and stored, because it cannot be re-evaluated on every render.
//
// Called both when the class is confirmed and from computePools(), so the value
// is present on the Attributes step (where it is shown beside the roll) and is
// re-rolled by Review's Reroll button along with the pools.
// Everything a class's dice bonuses actually rolled, in the grouped shape
// classBonuses reads. One helper so the call sites cannot disagree.
const rolledAll = () => ({
  attributes: S.attrBonuses || {},
  combat: S.rolledBonuses?.combat || {},
  saves: S.rolledBonuses?.saves || {},
});

function rollAttrBonuses(force = false) {
  // Idempotent unless forced. computePools() is called lazily whenever a later
  // step needs pools, and without this guard simply walking to Details silently
  // re-rolled a bonus the player had already read off the Attributes step.
  if (!force && S.attrBonuses && Object.keys(S.attrBonuses).length) return;

  // Combat and save bonuses a class states as dice — "+1D4 on initiative".
  // Rolled here with the attribute ones and stored, because both are read at
  // render time and a roll re-evaluated per render moves under the player.
  const byGroup = derive.diceBonusesByGroup(S.cls);
  S.rolledBonuses = { combat: {}, saves: {} };
  for (const g of ['combat', 'saves']) {
    for (const [k, dice] of Object.entries(byGroup[g] || {})) {
      const rolls = [dice].flat().map((d) => (typeof d === 'number' ? d : evalDice(d))).filter((v) => v != null);
      if (rolls.length) S.rolledBonuses[g][k] = rolls.reduce((a, b) => a + b, 0);
    }
  }

  S.attrBonuses = {};
  for (const [attr, dice] of Object.entries(derive.diceBonuses(S.cls))) {
    // A list when a race and an occupation both grant one to the same
    // attribute. Each rolls; the stored bonus is their total, so
    // `attribute_bonuses` stays one number per attribute and needs no migration.
    const rolls = [dice].flat().map((d) => (typeof d === 'number' ? d : evalDice(d))).filter((v) => v != null);
    if (rolls.length) S.attrBonuses[attr] = rolls.reduce((a, b) => a + b, 0);
  }
}

// ---------- pools ----------
// `force` distinguishes the lazy first computation from the Reroll button.
// Only the button re-rolls what has already been rolled.
function computePools(force = false) {
  const c = S.cls;
  // I.S.P. may come from a tier the character rolled rather than from the
  // class, so the pool is read off the composed object.
  const pc = psiClass();
  // What the class adds on top of each pool's own formula. Books state these as
  // "plus 4D6" over whatever the occupation gives, so the bonus rides along with
  // the roll and lands in the stored maximum.
  const pb = c.bonuses?.pools || {};
  S.pools = {
    hp: rollPoolFormula(c.hit_points_base, S.attrs, pb.hp),
    sdc: rollPoolFormula(c.sdc_base, S.attrs, pb.sdc),
    mdc: rollPoolFormula(c.mdc_base, S.attrs, pb.mdc),
    ppe: rollPoolFormula(c.ppe_base, S.attrs, pb.ppe),
    isp: pc.psionics ? rollPoolFormula(pc.psionics.isp_base, S.attrs, pb.isp) : null,
  };
  // Step 5 is "Equipment AND Money" (p.22) — every class starts with a sum of
  // coin as well as its kit. Rolled from the same formula parser as the pools,
  // so the Reroll button on Review covers it, and stored in bio because it is a
  // running number the player edits rather than anything the rules derive.
  rollAttrBonuses(force);

  const money = rollPoolFormula(c.starting_money, S.attrs);
  if (money == null) delete S.bio.money; else S.bio.money = String(money);
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
  'spells', 'psi', 'bio', 'pools', 'longLived', 'bioRolls',
  'psiRoll', 'psiShape', 'psiCategory', 'attrBonuses', 'rolledBonuses', 'abilities',
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
  S.cls = composeClass({
    rcc: S.classes.find((c) => c.id === d.class_id) || null,
    occ: S.occ ? S.classes.find((c) => c.id === S.occ) || null : null,
    // No psychic tier here: the roll happens on the Powers step, and psiClass()
    // folds it in from there while a build is in progress.
    character: { class_variant: S.variant, occ_class_variant: S.occVariant },
  });
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
      `<a href="sheet.html?id=${c.id}">${esc(c.name)}</a> <span class="muted">(${esc(className(c.class_id))}${c.occ_class_id ? ' ' + esc(className(c.occ_class_id)) : ''} L${c.level} · ${esc(c.campaign_name)})</span>`
    ).join(' &nbsp;·&nbsp; ')}</p>` : ''}
  </div>`;
}
function pickSystem(sys) {
  if (S.system !== sys) { S.cls = null; S.quiz = [null, null, null]; resetBuild(); }
  S.system = sys; S.step = 1; render();
}
function resetBuild() {
  S.attrMethods = {}; S.attrs = {}; S.attrRolls = {}; S.related = []; S.secondary = []; S.groupPicks = {};
  S.equipment = []; S.equipInit = false; S.pools = null;
  S.gearChoices = []; S.gearPicks = {};
  S.variant = null;
  S.occ = null; S.occVariant = null;
  S.abilities = [];
  S.spells = []; S.psi = []; S.bio = {}; S.longLived = false; S.bioRolls = {};
  S.psiRoll = null; S.psiShape = null; S.psiCategory = null; S.attrBonuses = {};
  S.rolledBonuses = { combat: {}, saves: {} };
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
  // Computed once: the sentence and the disabled state come from the same call.
  const blocker = classBlocker();
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
    ${abilityPicker()}
  </div>
  <div class="nav"><button class="btn btn-ghost" onclick="goStep(0)">&larr; Back</button>
  ${S.cls && blocker ? `<span class="nav-why">${esc(blocker)}</span>` : ''}
  <button class="btn btn-primary" ${blocker ? 'disabled' : ''} onclick="confirmClass()">Use this class &rarr;</button></div>`;
}
// A class's display name when the catalog is loaded, its id when not — the
// existing-characters list renders before /classes resolves on a cold start.
function className(id) {
  return S.classes.find((c) => c.id === id)?.name || id;
}

function classCard(c, score) {
  const sel = S.cls?.id === c.id ? ' sel' : '';
  const badge = score != null ? `<span class="tag score">match ${score}/6</span>` : '';
  return `<div class="pick${sel}" onclick="pickClass('${c.id}')">
    <h4>${esc(c.name)}</h4>
    <span class="tag">${esc(c.category)}</span><span class="tag">${esc(c.source_book)}</span>${
      needsOccupation(c) ? '<span class="tag">pairs with an O.C.C.</span>' : ''}${badge}
    <p class="muted small">${esc((c.lore || '').split('\n')[0].slice(0, 110))}…</p>
  </div>`;
}
function classDetail(c) {
  const reqs = c.attribute_requirements
    ? Object.entries(c.attribute_requirements).map(([k, v]) => `${k} ${v}+`).join(', ') : 'none';
  const sk = c.skills || {};
  return `<div id="class-detail" style="margin-top:16px; border-top:1px solid var(--border); padding-top:14px">
    <h3>${esc(c.name)}</h3>
    <p class="muted small">Requirements: ${esc(reqs)} &nbsp;·&nbsp; Class skills: ${(sk.occ_skills || []).length}
      &nbsp;·&nbsp; Related picks: ${sk.occ_related_skills?.count ?? 0} &nbsp;·&nbsp; Secondary picks: ${sk.secondary_skills?.count ?? 0}
      ${c.psionics ? ' · Psionics: ' + esc(c.psionics.type) : ''}${c.magic ? ' · Magic: ' + esc(c.magic.type) : ''}</p>
    <p class="small" style="margin-top:8px; line-height:1.55">${esc(c.lore || '')}</p>
    ${naturalAbilityList(c.natural_abilities)}
    ${listOrText('Side effects', c.side_effects)}
    ${listOrText('Restrictions', c.restrictions)}
    ${c.gm_notes ? `<p class="muted small" style="margin-top:8px"><b>GM notes:</b> ${esc(c.gm_notes)}</p>` : ''}
  </div>`;
}
// Powers the class simply grants — as opposed to the choose-groups the ability
// picker covers. Without this the Ley Line Walker's sixteen ley line powers
// appeared nowhere a player deciding on the class could read them.
function naturalAbilityList(list) {
  if (!Array.isArray(list) || !list.length) return '';
  const items = list.map((a) => {
    const name = typeof a === 'string' ? a : a?.name;
    const desc = a && typeof a === 'object' && a.description ? a.description : '';
    return `<li class="small"><b>${esc(name || '')}</b>${desc ? ` <span class="muted">&mdash; ${esc(desc)}</span>` : ''}</li>`;
  }).join('');
  return `<p class="small" style="margin-top:8px"><b>Natural abilities:</b></p>
    <ul style="margin:4px 0 0 18px">${items}</ul>`;
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
// Picking a class renders the detail, the variant/O.C.C./ability pickers and an
// enabled 'Use this class' button — ALL OF IT BELOW A GRID OF 20+ CARDS. On a
// laptop viewport that put every one of them about 1300px under the fold, and
// the page did not move, so the only on-screen change was a card tinting
// slightly. It read as a dead click, and got reported as one.
//
// So scroll the detail into view. The class list stays right above it, still
// one scroll away, and what to do next is now the thing you are looking at.
function pickClass(id) {
  const c = S.classes.find((x) => x.id === id);
  if (S.cls?.id !== id) resetBuild();
  S.cls = c;
  render();
  revealClassDetail();
}

// render() replaces innerHTML, so the node is looked up after it, not before.
//
// Instant, not smooth. Smooth reads better in principle and is wrong here for
// two reasons: the complaint being fixed is that the click looked dead, and a
// half-second animation is half a second of it still looking dead — and
// `behavior: 'smooth'` needs a compositor running, so it silently does nothing
// in an automated browser, which means the fix could not be tested. Instant
// scrolling is verifiable, and it is also the unambiguous answer to 'did that
// do anything'.
function revealClassDetail() {
  // The outstanding choice if there is one, the detail otherwise. Scrolling to
  // the detail alone put a Ley Line Walker's power picker back below the fold,
  // which is the same failure one screen further down.
  const { anchor } = classBlock();
  const el = document.getElementById(anchor || '') || document.getElementById('class-detail');
  if (!el || typeof el.scrollIntoView !== 'function') return;
  el.scrollIntoView({ behavior: 'auto', block: 'start' });
}
// A class with variants is not usable until one is chosen — a Dragon is always
// some particular age, and defaulting to the first stage would pick for you.
// What is still outstanding before this class can be used, as a sentence, or
// '' when nothing is. The button's disabled state is derived from this rather
// than computed alongside it, so the two cannot disagree — a greyed button
// with no reason, or a reason next to a live button, are both worse than
// either problem alone.
//
// This exists because a disabled button IS the whole explanation otherwise.
// Picking a Ley Line Walker greys it out with no visible cause; the answer
// (choose a power) is real, reasonable, and was never stated.
function classBlocker() { return classBlock().why; }

// The blocking requirement AND where on the page to resolve it. One function,
// because the sentence, the disabled button and the scroll target all have to
// describe the same requirement or they send the reader three ways.
function classBlock() {
  if (!S.cls) return { why: 'Pick a class to continue.', anchor: null };
  if ((S.cls.variants || []).length && !S.variant) {
    return { why: `Choose which ${S.cls.name} to continue.`, anchor: 'variant-picker' };
  }
  // Every power the class asks for must be chosen before the rolls that depend
  // on them. Same reasoning as an unresolved gear choice: the book intends the
  // character to have them, so leaving one blank is an oversight rather than a
  // deliberate omission. Unspent SKILL picks are banked instead, because those
  // are earned over time.
  const owed = abilityGroups(S.cls).reduce((n, g) => n + (+g.choose || 0), 0);
  const short = owed - S.abilities.length;
  if (short > 0) {
    return { why: `Choose ${short} more ${short === 1 ? 'power' : 'powers'} to continue.`,
             anchor: 'ability-picker' };
  }
  // An ability that names occupations (Magic Powers) is not resolved until
  // one of them is chosen - same rule as the ability count above.
  const occNeed = abilityOccOptions(S.cls, S.abilities);
  if (occNeed && (!S.occ || !occNeed.options.includes(S.occ))) {
    return { why: `Choose an occupation for ${occNeed.name} to continue.`, anchor: 'occ-picker' };
  }
  return { why: '', anchor: null };
}

function canUseClass() { return !classBlocker(); }

// Which stage of the class. Shown only when the class has stages, so every
// other class is unaffected.
function variantPicker() {
  const variants = S.cls?.variants || [];
  if (!variants.length) return '';
  return `<div class="panel-inset" id="variant-picker">
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
  // A chosen ability that names occupations claims this picker: the choice
  // stops being optional and the options narrow to what the ability lists.
  const occNeed = abilityOccOptions(S.cls, S.abilities);
  if (occNeed) {
    const chosen = S.occ ? S.classes.find((c) => c.id === S.occ) : null;
    return `<div class="panel-inset" id="occ-picker">
    <h3>${esc(occNeed.name)} <span class="muted small">&mdash; pick the practitioner</span></h3>
    <p class="muted small">Taking <b>${esc(occNeed.name)}</b> means having one of these
      occupations composed into the character &mdash; its magic, its abilities and its
      training program all arrive with it.</p>
    ${!S.occ || !occNeed.options.includes(S.occ) ? `<p class="warn">Choose one to continue.</p>` : ''}
    <div class="rowline">
      <select onchange="pickOcc(this.value)">
        <option value="">&mdash; choose &mdash;</option>
        ${occNeed.options.map((oid) => {
          const c = S.classes.find((x) => x.id === oid);
          return c
            ? `<option value="${esc(oid)}"${S.occ === oid ? ' selected' : ''}>${esc(c.name)}</option>`
            : `<option value="" disabled>${esc(oid)} (not in the catalog yet)</option>`;
        }).join('')}
      </select>
    </div>
    ${chosen ? `<p class="small">Related skills: <b>${chosen.skills?.occ_related_skills?.count ?? 0}</b>
      &middot; Secondary: <b>${chosen.skills?.secondary_skills?.count ?? 0}</b>
      &middot; the occupation allowances replace those of this class.</p>` : ''}
  </div>`;
  }
  if (S.cls?.category !== 'rcc') return '';
  const options = S.classes.filter((c) => c.system === S.system && c.category === 'occ');
  if (!options.length) return '';
  const chosen = S.occ ? S.classes.find((c) => c.id === S.occ) : null;
  // The usual structure is a race and then an occupation. Presented as the
  // expected next step rather than an optional extra, because that is what it
  // is — but never blocking, since some races genuinely stand alone.
  const needs = needsOccupation(S.cls);
  return `<div class="panel-inset">
    <h3>Occupation <span class="muted small">— ${needs ? 'normally required' : 'optional for this race'}</span></h3>
    <p class="muted small">${needs
      ? `<b>${esc(S.cls.name)}</b> grants no related or secondary skills of its own, so alone it
         gives you nothing to choose. A character is normally a race <em>and</em> an occupation:
         the race sets the body, the O.C.C. sets what was learned.`
      : `<b>${esc(S.cls.name)}</b> grants its own skills, so it can stand alone — but most
         characters are a race <em>and</em> an occupation, and taking one adds its skills to this.`}</p>
    ${needs && !S.occ ? `<p class="warn">No occupation chosen. You can continue, and this character
      will have no related or secondary skills at all.</p>` : ''}
    <div class="rowline">
      <select onchange="pickOcc(this.value)">
        <option value="">— none (this race stands alone) —</option>
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

// Abilities the class asks the player to choose. On the CLASS step and not a
// step of its own, because an ability can add to attributes and pools — the
// Godling's Super-Tough is +1D6 P.E. and +3D4x10 M.D.C. — and both are rolled on
// the two steps after this one. Choosing later would mean re-rolling what the
// player had already read.
function abilityGroups(cls) {
  return (cls?.special_abilities || []).filter((e) => e && e.choose);
}

function abilityPicker() {
  const groups = abilityGroups(S.cls);
  if (!groups.length) return '';
  const defs = new Map((S.cls.special_abilities || [])
    .filter((e) => e && typeof e.name === 'string' && !e.choose)
    .map((d) => [d.name.trim().toLowerCase(), d]));

  return groups.map((g, gi) => {
    const limit = +g.choose || 1;
    const picked = S.abilities.length;
    const opts = (g.from || []).map((name) => {
      const def = defs.get(String(name).trim().toLowerCase());
      const times = S.abilities.filter((n) => n === name).length;
      const repeatable = def?.repeatable === true;
      const full = picked >= limit;
      return `<div class="chkrow">
        <button class="btn btn-sm btn-ghost" ${times === 0 ? 'disabled' : ''}
          onclick="dropAbility('${esc(name).replace(/'/g, "&#39;")}')">&minus;</button>
        <button class="btn btn-sm" ${full || (times > 0 && !repeatable) ? 'disabled' : ''}
          onclick="takeAbility('${esc(name).replace(/'/g, "&#39;")}')">+</button>
        <span><b>${esc(name)}</b>${times > 1 ? ` <span class="tag">taken ${times}&times;</span>`
          : times === 1 ? ' <span class="tag">taken</span>' : ''}
          ${repeatable ? '<span class="muted small">&nbsp;may be taken twice</span>' : ''}</span>
        ${def?.description ? `<div class="muted small" style="flex-basis:100%">${esc(def.description)}</div>` : ''}
        ${times > 1 && def?.on_repeat ? `<div class="small" style="flex-basis:100%"><b>Twice:</b> ${esc(def.on_repeat)}</div>` : ''}
      </div>`;
    }).join('');

    return `<div class="panel-inset"${gi === 0 ? ' id="ability-picker"' : ''}>
      <h3>Powers <span class="muted small">&mdash; choose ${limit}</span></h3>
      <p class="muted small">Chosen now rather than later: these can add to attributes and pools,
        and both are rolled on the next two steps.</p>
      <p class="small ${picked === limit ? 'ok' : 'warn'}">${picked} of ${limit} chosen</p>
      ${opts}
    </div>`;
  }).join('');
}

function takeAbility(name) {
  const limit = abilityGroups(S.cls).reduce((n, g) => n + (+g.choose || 0), 0);
  if (S.abilities.length >= limit) return;
  S.abilities.push(name);
  render();
}

function dropAbility(name) {
  const i = S.abilities.lastIndexOf(name);
  if (i >= 0) S.abilities.splice(i, 1);
  // If the dropped ability was the one claiming the occupation slot and no
  // remaining pick still needs it, release the slot - keeping a practitioner
  // chosen through an ability that is no longer taken would be surprising.
  const still = abilityOccOptions(S.cls, S.abilities);
  if (!still && S.occ) {
    const def = (S.cls?.special_abilities || []).find((d) => d?.name === name);
    if (Array.isArray(def?.occ_options) && def.occ_options.includes(S.occ)) {
      S.occ = null; S.occVariant = null;
    }
  }
  render();
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
  S.cls = composeClass({
    rcc: S.cls,
    occ: S.occ ? S.classes.find((c) => c.id === S.occ) || null : null,
    character: { class_variant: S.variant, occ_class_variant: S.occVariant, abilities: S.abilities },
  });
  // Rolled here so the Attributes step, which comes next, can show the bonus
  // beside the roll it modifies. computePools() re-rolls it later if asked.
  rollAttrBonuses(true);
  S.step = 2;
  render();
}

// Step 2 — attributes
function renderAttributes() {
  const classBonus = derive.classBonuses(skillBonusClass(), 1, rolledAll());
  // Split out so the label can say where a bonus came from. Once skills fold
  // into the same block, "+2 from Glitter Boy" is a lie whenever the +2 is
  // Boxing's - and an attribute bonus the player cannot trace is worse than
  // one shown a step later, which is what this change set out to fix.
  const classOnlyBonus = derive.classBonuses(S.cls, 1, rolledAll());
  const reqs = S.cls.attribute_requirements || {};
  const spent = pbSpent();
  const rows = ATTRS.map((a) => {
    const m = method(a);
    const v = S.attrs[a];
    const dice = S.cls.attribute_dice?.[a];
    let control;
    if (m === 'roll') {
      // An exceptional roll is rare enough that an unexplained 24 off a 3d6
      // reads as a bug, and the second die — earned only by rolling a six on
      // the first — reads as one even when it is correct. So show the working.
      const r = S.attrRolls[a];
      const why = r
        ? ` <span class="attr-note ok">${esc(r.notation)} ${r.base}${r.modifier ? (r.modifier > 0 ? '+' : '') + r.modifier : ''}
            · exceptional +${r.exceptional.join(', +')}</span>` : '';
      control = `<button class="btn btn-sm" onclick="doRoll('${a}')">Roll ${esc(dice || '3d6')}</button> <b>${v ?? '—'}</b>${why}`;
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
    const floor = classBonus.attribute_minimums?.[a];
    // A dice bonus reads the same as a flat one here; what differs is that the
    // number was rolled, which the class name beside it already implies.
    const raised = v != null && floor != null && (v + (add || 0)) < floor;
    // Where it came from: the class, the skills taken so far, or both.
    const fromClass = classOnlyBonus.attributes[a] || 0;
    const fromSkills = (add || 0) - fromClass;
    const source = !fromSkills ? esc(S.cls.name)
      : (!fromClass ? 'skills taken' : `${esc(S.cls.name)} + skills taken`);
    const boost = add && v != null
      ? ` <span class="attr-note ok">${add > 0 ? '+' : ''}${add} from ${source} = ${v + add}</span>` : '';
    const floorNote = raised
      ? ` <span class="attr-note ok">minimum ${floor} for ${esc(S.cls.name)}</span>` : '';
    return `<tr><td><b>${a}</b></td>
      <td><select onchange="setMethod('${a}', this.value)">
        <option value="roll" ${m === 'roll' ? 'selected' : ''}>Random roll</option>
        <option value="point" ${m === 'point' ? 'selected' : ''}>Point-buy</option>
        <option value="manual" ${m === 'manual' ? 'selected' : ''}>Manual entry</option>
      </select></td>
      <td>${control}</td><td>${req}${boost}${floorNote}${dice ? ` <span class="attr-note">racial dice: ${esc(dice)}</span>` : ''}</td></tr>`;
  }).join('');

  const unmet = Object.entries(reqs).filter(([k, min]) => (S.attrs[k] ?? -1) < min);
  const missing = ATTRS.filter((a) => S.attrs[a] == null);
  const usesPB = ATTRS.some((a) => method(a) === 'point');
  const over = spent > PB_POOL;
  const canNext = missing.length === 0 && unmet.length === 0 && !over;
  // The panel already warns about missing values and unmet minimums, and this
  // repeats them beside the button on purpose: the button is where you look
  // when you are stuck, and a warning further up the page is not an answer to
  // "why can't I continue". Overspending point-buy had NO warning at all —
  // only a number turning red — so that case is new information.
  const attrWhy = missing.length ? `Still to roll or enter: ${missing.join(', ')}.`
    : unmet.length ? `Class minimum not met: ${unmet.map(([k, v]) => `${k} ${v}+`).join(', ')}.`
    : over ? 'Point-buy pool overspent — free up points to continue.'
    : '';

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
  ${attrWhy ? `<span class="nav-why">${esc(attrWhy)}</span>` : ''}
  <button class="btn btn-primary" ${canNext ? '' : 'disabled'} onclick="goStep(3)">Skills &rarr;</button></div>`;
}
// A roll's breakdown is cleared whenever the value stops being that roll —
// otherwise "exceptional +4" hangs beside a number the player typed by hand.
function setMethod(a, m) { S.attrMethods[a] = m; if (m !== 'roll') S.attrRolls[a] = null; if (m === 'point') S.attrs[a] = S.attrs[a] ?? PB_BASE; render(); }
function setAllMethod(m) { ATTRS.forEach((a) => { S.attrMethods[a] = m; if (m !== 'roll') S.attrRolls[a] = null; if (m === 'point') S.attrs[a] = S.attrs[a] ?? PB_BASE; }); render(); }
function doRoll(a) { setRoll(a); render(); }
function rollAll() { ATTRS.forEach((a) => { S.attrMethods[a] = 'roll'; setRoll(a); }); render(); }
function manualSet(a, v) { const n = parseInt(v, 10); S.attrs[a] = Number.isFinite(n) && n > 0 ? n : null; S.attrRolls[a] = null; render(); }
function pbAdj(a, delta) {
  const cur = S.attrs[a] ?? PB_BASE;
  const next = cur + delta;
  if (next < PB_FLOOR || next > PB_CAP) return;
  S.attrs[a] = next;
  S.attrRolls[a] = null;
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

// A forbidden skill is never offered rather than offered and rejected: the
// books state these limits per category, so a player should not be able to
// build most of a character before being told a pick was never legal.
function catalogFor(categories) {
  return S.skillCatalog.filter((sk) =>
    categoryAllows(categories, sk) &&
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
// `base` states the percentage outright; `bonus` adds to whatever the skill's
// own base is. A choice group needs the second: "three languages of choice at
// +30%" cannot be one number, because the members of a category start at
// different percentages. Writing 80 there gave every pick 80 regardless.
//
// A non-percentile skill (a W.P., hand to hand) stays at zero: a percentage
// bonus has nothing to modify, exactly as the I.Q. bonus already works.
function resolveSkill(name, explicit = {}) {
  const cat = skillByName().get(name) || {};
  const catBase = cat.base ?? 0;
  const base = explicit.base ?? (explicit.bonus && catBase ? catBase + explicit.bonus : catBase);
  return {
    base,
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
// The class with the bonuses its SKILLS grant folded in.
//
// Boxing is "+1 attack per melee, +2 parry & dodge, +1 roll, +2 P.S." The sheet
// has applied those since the bonuses column landed, but the wizard did not:
// composeClass() runs on the Class step, before a single skill is chosen, so
// there is nothing to fold in at that point. The numbers appeared only after
// saving, which is the same values arriving late and reads as a bug.
//
// Deliberately a separate helper from psiClass() rather than an extension of
// it. They answer different questions — psiClass() resolves what the class IS
// once a rolled tier is known, this resolves what the character's own choices
// have added — and they are needed on different steps.
//
// takenNames() is the single source for "which skills does this character
// hold", already used by the pickers, so a skill counted here is exactly one
// the wizard shows as taken.
function skillBonusClass() {
  if (!S.cls) return S.cls;
  const held = takenNames();
  const rows = (S.skillCatalog || []).filter((sk) => held.has(String(sk.name).toLowerCase()));
  const extra = bonusesFromSkills(rows);
  if (!extra) return S.cls;
  return { ...S.cls, bonuses: sumBonusGroups(S.cls.bonuses, extra) };
}

function renderSkills() {
  // The COMPOSED class: a rolled major psionic has half the related-skill
  // allowance, and the Skills step has to show the number that actually applies.
  const sk = psiClass().skills || {};
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
      <span class="pct">${esc((s.categories || []).map(categoryLabel).join(', '))} ${picked.length}/${s.choose} chosen</span></div>${noteHtml}${opts}`;
  }).join('');

  const schedule = relatedCfg.schedule || [];

  // The category gate already narrows these, which is why 128 skills has been
  // survivable — but "Any category" on the secondary list is the whole catalog,
  // and a checkbox list you have to scroll to search is not a search.
  // A ticked skill always stays visible, or filtering would appear to un-pick it.
  const pickList = (catalog, chosen, kind, limit, query) => {
    // Custom languages exist on the character but not in the catalog, so the
    // concat below would never surface them — synthesize their rows from the
    // Other entry's numbers or a pick could not be seen or un-picked.
    const custom = chosen
      .filter((n) => isLanguageName(n) && !catalog.some((s) => s.name === n))
      .map((n) => ({ ...(skillByName().get(LANGUAGE_OTHER) || {}), name: n }));
    const shown = Picker.filter(catalog, query)
      .concat(catalog.filter((s) => chosen.includes(s.name) && !Picker.match(s, query)))
      .concat(custom);
    if (!shown.length) return '<p class="muted small">Nothing matches that filter.</p>';
    // Grouped by category. "Any category" on the secondary list is the whole
    // catalog, and a flat run of 200+ checkboxes gives no sense of where you are
    // in it. Sorted by category then name so the headings come out in a stable
    // order rather than the catalog's.
    const ordered = [...shown].sort((a, b) =>
      (a.category || '\uffff').localeCompare(b.category || '\uffff')
      || (a.name || '').localeCompare(b.name || ''));
    const sizes = ordered.reduce((m, x) => { const g = x.category || 'Uncategorized';
      return m.set(g, (m.get(g) || 0) + 1); }, new Map());
    let lastCat = null;
    return ordered.map((s) => {
      const cat = s.category || 'Uncategorized';
      const head = cat !== lastCat
        ? `<div class="pick-group">${esc(cat)}<span class="pick-group-n">${sizes.get(cat)}</span></div>`
        : '';
      lastCat = cat;
      const on = chosen.includes(s.name);
      const blocked = !on && (taken.has(s.name.toLowerCase()) || chosen.length >= limit);
      const hint = s.name === LANGUAGE_OTHER
        ? ' <span class="muted small">— once per language; you will be asked which</span>' : '';
      // The category is the heading now, so the row carries only its numbers.
      return head + `<label class="chkrow" style="${blocked ? 'opacity:0.45' : 'cursor:pointer'}">
        <input type="checkbox" ${on ? 'checked' : ''} ${blocked ? 'disabled' : ''}
          data-act="skill" data-kind="${kind}" data-name="${esc(s.name)}">
        <span>${esc(s.name)}${hint}</span>
        <span class="pct">${s.base ? s.base + '%' + (s.per_level ? ' +' + s.per_level + '/lvl' : '') : '—'}</span>
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
        <p class="muted small">Allowed: ${esc((relatedCfg.categories || []).map(categoryLabel).join(', ') || '—')}</p>
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
  // Language: Other is taken once per language, each a separate skill named
  // for it — so the row prompts instead of toggling, and never reads as
  // "already picked". Un-picking happens on the named row it created.
  if (name === LANGUAGE_OTHER) {
    // No limit check here: the row's checkbox is disabled at the limit by the
    // same blocked logic every other row gets.
    const typed = window.prompt('Which language? (saved as "Language: <name>")');
    if (typed === null) return;
    const full = languageSkillName(typed);
    if (!full) return;
    if (takenNames().has(full.toLowerCase())) { alert(full + ' is already on this character.'); return; }
    list.push(full);
    render();
    return;
  }
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
  // would undo every hand-added or removed row. The guard also makes a dice
  // quantity (the Priest of Light's 1D6 vials of holy water) roll ONCE: the
  // rolled number lands in S.equipment, which the draft persists.
  if (S.equipInit) return;
  S.equipment = starting.flatMap((eq) => {
    if (isGearChoice(eq)) return [];
    const item = findItem(eq.item_id);
    const qty = rollQuantity(eq.qty ?? 1);
    return [item
      ? { item_id: item.id, name: item.name, qty, source: 'starting' }
      : { custom_name: eq.item_id.replace(/-/g, ' '), qty, source: 'starting', notes: 'starting gear (not in item catalog yet)' }];
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

  // Names what is outstanding rather than counting it. `Still to choose:
  // energy pistol, vibro-blade` tells you where to look; `2 gear choices`
  // makes you go and find them. Falls back to a count only when a class left
  // a choice group unlabelled.
  const outstandingGroups = gearChoicesOutstanding();
  const outstanding = outstandingGroups.length;
  const gearLabels = outstandingGroups.map((c) => c.label).filter(Boolean);
  const gearWhy = !outstanding ? ''
    : gearLabels.length === outstanding
      ? `Still to choose: ${gearLabels.join(', ')}.`
      : `${outstanding} gear choice${outstanding === 1 ? '' : 's'} still to make.`;

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
  ${gearWhy ? `<span class="nav-why">${esc(gearWhy)}</span>` : ''}
  <button class="btn btn-primary" ${outstanding ? 'disabled' : ''} onclick="goStep(5)">Powers &rarr;</button></div>`;
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
    // A class may name the exact powers its picks come from - the Burster's
    // "select three minor psionic powers from the following list". A named
    // list is MORE specific than a category gate, so it replaces it rather
    // than narrowing within it, exactly as a skill choice-group's `from`
    // list does.
    from: Array.isArray(p.powers_from) && p.powers_from.length ? p.powers_from.map(String) : null,
  };
}

// The class as this character actually plays it, once a rolled tier is folded
// in. Everything on this step reads THIS rather than S.cls, so a rolled psychic
// and a born one go down exactly the same path — the alternative was a second
// parallel set of branches for "psionics, but from the table".
function psiClass() {
  return withRolledPsionics(S.cls, { psychic_tier: S.psiRoll?.tier, psychic_shape: S.psiShape });
}

// Only a class that grants no psionics of its own rolls, and only if its race
// has psychic potential at all. The book offers the table and the psychic
// O.C.C.s as alternatives, not as things that stack.
const canRollPsionics = () => classRollsForPsionics(S.cls);

// Rolling a major psionic halves the related-skill allowance (p.21), and this
// wizard asks for skills BEFORE powers — the book asks in the other order. So a
// roll can invalidate picks already made. Trim the excess and say so, rather
// than letting the character reach Review holding more than the class allows.
//
// Trims from the end, so the picks made first survive.
function trimRelatedToAllowance() {
  const limit = psiClass().skills?.occ_related_skills?.count ?? 0;
  if (S.related.length <= limit) { S.psiTrimmed = 0; return; }
  S.psiTrimmed = S.related.length - limit;
  S.related = S.related.slice(0, limit);
}

function doPsiRoll() {
  S.psiRoll = rollPsionics();
  trimRelatedToAllowance();
  // A new roll invalidates whatever the previous one allowed.
  S.psiShape = S.psiRoll.tier ? PSIONIC_TIER_RULES[S.psiRoll.tier].shapes[0].id : null;
  S.psiCategory = null;
  S.psi = [];
  render();
}
// "A player may skip step three entirely if he or she does not want a character
// with psionics." Recorded as a deliberate no rather than an unrolled blank.
function skipPsiRoll() {
  S.psiRoll = { roll: null, tier: null, skipped: true };
  trimRelatedToAllowance();
  S.psiShape = null; S.psiCategory = null; S.psi = [];
  render();
}
function setPsiShape(id) {
  S.psiShape = id; S.psiCategory = null; S.psi = []; render();
}
function setPsiCategory(cat) {
  S.psiCategory = cat || null;
  // Powers already chosen from another category are no longer legal.
  S.psi = S.psi.filter((n) => S.psiCatalog.find((p) => p.name === n)?.category === S.psiCategory);
  render();
}
// Step 3 as the book runs it: one percentile roll, and most characters get
// nothing. The odds are shown because a 74% chance of "no psionics" looks like
// a broken button otherwise.
function psiRollHtml() {
  const r = S.psiRoll;
  const odds = `<p class="muted small">01-09 major &nbsp;·&nbsp; 10-25 minor &nbsp;·&nbsp; 26-00 none.
    Most characters get nothing, and that is the common result rather than a failure.</p>`;

  if (!r) {
    return `<h3>Psionics</h3>
      <p class="muted">This class grants no psychic powers of its own, so the character rolls for them.</p>
      ${odds}
      <p><button class="btn btn-primary" onclick="doPsiRoll()">🎲 Roll for psionics</button>
        <button class="btn btn-ghost" onclick="skipPsiRoll()">Skip — no psionics</button></p>`;
  }

  const outcome = r.skipped
    ? `<b>Skipped</b> — this character has no psychic powers.`
    : `Rolled <b>${r.roll}</b> — ${r.tier ? `<b>${esc(r.tier)} psionic</b>` : '<b>no psionics</b>'}.`;

  // The major psionic's price, and what it cost this character in particular.
  const penalty = r.tier === 'major'
    ? `<p class="attr-note">A major psionic's related-skill allowance is halved
       (now ${psiClass().skills?.occ_related_skills?.count ?? 0}).
       ${S.psiTrimmed ? `<b>${S.psiTrimmed} already-chosen ${S.psiTrimmed === 1 ? 'skill was' : 'skills were'} removed.</b>` : ''}</p>` : '';

  // A tier the roll produced brings a choice of allowance with it, where the
  // book gives one. A minor psychic has only the single shape, so no radio
  // group is drawn for it.
  const spec = r.tier ? PSIONIC_TIER_RULES[r.tier] : null;
  const shapes = spec && spec.shapes.length > 1
    ? `<p class="small" style="margin-top:8px">How the powers are taken:</p>` + spec.shapes.map((s) =>
        `<label class="chkrow" style="cursor:pointer"><input type="radio" name="psi-shape"
          ${S.psiShape === s.id ? 'checked' : ''} onchange="setPsiShape('${s.id}')">
          <span>${esc(s.label)}</span></label>`).join('')
    : '';

  const shape = r.tier ? psionicShape(r.tier, S.psiShape) : null;
  const cats = shape && shape.categories === 1
    ? `<div class="rowline" style="margin-top:8px">
        <label class="small" style="min-width:132px">Category</label>
        <select onchange="setPsiCategory(this.value)" style="flex:1">
          <option value=""${S.psiCategory ? '' : ' selected'}>— choose —</option>
          ${PSIONIC_CATEGORIES.map((c) => `<option value="${c}"${c === S.psiCategory ? ' selected' : ''}>${c}</option>`).join('')}
        </select></div>`
    : '';

  return `<h3>Psionics</h3>
    <p>${outcome}</p>
    ${r.tier ? `<p class="muted small">I.S.P. ${esc(spec.isp_base)} — rolled on Review.</p>` : odds}
    ${penalty}
    ${shapes}${cats}
    <p style="margin-top:8px"><button class="btn btn-sm btn-ghost" onclick="doPsiRoll()">↻ reroll</button>
      ${r.tier ? `<button class="btn btn-sm btn-ghost" onclick="skipPsiRoll()">Take none</button>` : ''}</p>`;
}

// Group headers for the two picker lists, same idiom as the sheet's
// Psionics & Magic box (.power-group). The list arrives as filter matches
// plus chosen-but-unmatched entries appended so a pick never vanishes —
// sorting the combined list files those into their proper groups instead of
// leaving them dangling at the end. With a header per group, the per-row
// "L3 ·" / "Healing ·" prefix is redundant and gone.
function spellGroupRows(list, count) {
  const sorted = [...list].sort((a, b) =>
    ((a.level ?? Infinity) - (b.level ?? Infinity)) || (a.name || '').localeCompare(b.name || ''));
  const sizes = sorted.reduce((m, x) => { const g = x.level != null ? `Level ${x.level}` : 'Unleveled';
    return m.set(g, (m.get(g) || 0) + 1); }, new Map());
  let last = null;
  return sorted.map((sp) => {
    const group = sp.level != null ? `Level ${sp.level}` : 'Unleveled';
    const head = group !== last
      ? `<div class="pick-group">${esc(group)}<span class="pick-group-n">${sizes.get(group)}</span></div>`
      : '';
    last = group;
    const on = S.spells.includes(sp.name);
    const blocked = !on && S.spells.length >= count;
    return head + `<label class="chkrow" style="${blocked ? 'opacity:0.45' : 'cursor:pointer'}">
      <input type="checkbox" ${on ? 'checked' : ''} ${blocked ? 'disabled' : ''}
        data-act="power" data-kind="spell" data-name="${esc(sp.name)}">
      <span>${esc(sp.name)}${sp.ppe_note ? ` <span class="muted small">&mdash; ${esc(sp.ppe_note)}</span>` : ''}</span>
      <span class="pct">${sp.ppe}${sp.ppe_note && sp.ppe > 0 ? '+' : ''} P.P.E.</span></label>`;
  }).join('');
}

function psiGroupRows(list, count) {
  const sorted = [...list].sort((a, b) =>
    (a.category || '￿').localeCompare(b.category || '￿') || (a.name || '').localeCompare(b.name || ''));
  const sizes = sorted.reduce((m, x) => { const g = x.category || 'Uncategorized';
    return m.set(g, (m.get(g) || 0) + 1); }, new Map());
  let last = null;
  return sorted.map((p) => {
    const group = p.category || 'Uncategorized';
    const head = group !== last
      ? `<div class="pick-group">${esc(group)}<span class="pick-group-n">${sizes.get(group)}</span></div>`
      : '';
    last = group;
    const on = S.psi.includes(p.name);
    const blocked = !on && S.psi.length >= count;
    return head + `<label class="chkrow" style="${blocked ? 'opacity:0.45' : 'cursor:pointer'}">
      <input type="checkbox" ${on ? 'checked' : ''} ${blocked ? 'disabled' : ''}
        data-act="power" data-kind="psi" data-name="${esc(p.name)}">
      <span>${esc(p.name)}${p.isp_note ? ` <span class="muted small">&mdash; ${esc(p.isp_note)}</span>` : ''}</span>
      <span class="pct">${p.isp}${p.isp_note && p.isp > 0 ? '+' : ''} I.S.P.</span></label>`;
  }).join('');
}

function renderPowers() {
  const magic = S.cls.magic || null;
  const cls = psiClass();
  const psi = psiConfig(cls);
  const rolling = canRollPsionics();
  let inner = '';
  if (!magic && !psi && !rolling) {
    inner = `<p class="muted">This class has no spellcasting or psionics — carry on.</p>`;
  }
  if (rolling) inner += psiRollHtml();
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
      spellGroupRows(list, count);
  }
  if (psi) {
    const tier = cls.psionics.type;
    // A shape that allows a single category narrows the pool to the one chosen.
    // Until it IS chosen the list stays empty rather than showing everything —
    // offering powers the character cannot legally take reads as a bug.
    const shape = cls.psionics.from_roll ? psionicShape(tier, S.psiShape) : null;
    const single = shape && shape.categories === 1;
    const allowed = single ? (S.psiCategory ? [S.psiCategory] : []) : psi.cats;
    // A named list replaces the category gate; the book has already said
    // exactly which powers this class may take.
    const named = psi.from && new Set(psi.from.map((n) => n.toLowerCase()));
    const inCategory = named
      ? S.psiCatalog.filter((p) => inSystem(p) && named.has(String(p.name).toLowerCase()))
      : S.psiCatalog.filter((p) => inSystem(p) && allowed.includes(p.category));
    // A name the catalog does not carry would silently shrink the list, so
    // say so - the same reasoning the skill cross-reference uses.
    const unknownNamed = named
      ? psi.from.filter((n) => !S.psiCatalog.some((x) => String(x.name).toLowerCase() === n.toLowerCase()))
      : [];
    // Two gates, and they are not the same. The category gate has always been
    // here (Super is master-only). This is the per-power one: a book can state
    // that an individual power needs a higher tier than its category implies.
    const pool = inCategory.filter((p) => derive.meetsTier(tier, p.min_tier));
    const gated = inCategory.length - pool.length;
    const list = Picker.filter(pool, S.psiFilter)
      .concat(pool.filter((p) => S.psi.includes(p.name) && !Picker.match(p, S.psiFilter)));

    inner += `<h3>Psionic powers — ${S.psi.length}/${psi.count}
      <span class="muted small">(${esc(tier)} psychic · ${psi.from ? 'from the class list' : (single && S.psiCategory ? [S.psiCategory] : psi.cats).join(', ')})</span></h3>`
      + (single && !S.psiCategory
        ? `<p class="attr-note">Choose a category above — all ${psi.count} powers come from the same one.</p>` : '') +
      // Say that something is being withheld, so a short list reads as a rule
      // rather than as a gap in the catalog. Counted against the tier-gated
      // pool, not the filtered view — the filter is yours, the gate is not.
      (gated ? `<p class="attr-note">${gated} more ${gated === 1 ? 'power needs' : 'powers need'} a higher psychic tier than ${esc(tier)}.</p>` : '') +
      (unknownNamed.length ? `<p class="attr-note">${unknownNamed.length} named ${unknownNamed.length === 1 ? 'power is' : 'powers are'} not in the catalog yet: ${esc(unknownNamed.join(', '))}.</p>` : '') +
      Picker.inputHtml({ id: 'psi-filter', value: S.psiFilter, placeholder: 'Filter powers…',
        shown: Picker.filter(pool, S.psiFilter).length, total: pool.length }) +
      psiGroupRows(list, psi.count);
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
  // Money is rolled with the pools, and this step is the first place it is
  // shown — without this the field sits empty here and mysteriously fills in on
  // Review. Lazy and idempotent, so arriving via Review does not re-roll.
  if (!S.pools) computePools();
  const d = derive.bio(S.attrs, null, derive.classBonuses(skillBonusClass(), 1, rolledAll()));
  $('app').innerHTML = `
  <div class="panel">
    <h2>Details <span class="muted small">— ${esc(S.cls.name)}</span></h2>
    <p class="muted">The identity block from the printed sheet. <b>Alignment is required</b> — the book
      calls it the one mandatory part of this step, and there is deliberately no neutral. Everything
      else is optional and can be filled in later on the character sheet.</p>
    <p><button class="btn btn-sm" onclick="rollBioAll()">🎲 Roll the background tables</button>
      <span class="muted small">Fills only what is still blank. Every 🎲 rolls its own table (p.32-33);
      all of it is optional.</span></p>
    <div class="cols" style="margin-top:12px">
      <div>${BIO_FIELDS.slice(0, BIO_HALF).map(bioInput).join('')}</div>
      <div>${BIO_FIELDS.slice(BIO_HALF).map(bioInput).join('')}</div>
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
  // Alignment is the one field on this step the book calls mandatory, and the
  // only one with a closed set of answers. Everything else here is free text
  // flavour that can stay blank forever.
  const control = key === 'alignment'
    ? `<select onchange="setBio('alignment', this.value)" style="flex:1">${rules.alignmentOptions(S.bio.alignment)}</select>`
    : `<input type="text" value="${esc(S.bio[key] ?? '')}" onchange="setBio('${key}', this.value)" style="flex:1">`;
  // Every field the book prints a table for gets a die beside it. The rest are
  // free text: there is no table for a character's name.
  const rollable = !!rules.BACKGROUND_TABLES[key];
  const die = rollable ? ` <button class="btn btn-sm btn-ghost" title="Roll on the ${esc(rules.BACKGROUND_TABLES[key].label)} table"
    onclick="rollBio('${key}')">🎲</button>` : '';
  // The Age table's own note: double the years for an elf, dwarf or changeling.
  const ageOpt = key === 'age'
    ? ` <label class="small" title="Multiply the rolled age by two, per the table's note">
        <input type="checkbox" ${S.longLived ? 'checked' : ''} onchange="setLongLived(this.checked)"> long-lived race (×2)</label>` : '';
  return `<div class="rowline">
    <label class="small" style="min-width:132px">${esc(bioLabel([key, label]))}${key === 'alignment' ? ' <span class="req">*</span>' : ''}</label>
    ${control}${die}${ageOpt}
  </div>`;
}
// The book's tables are optional and nothing derives from them, so a roll just
// fills the field — no confirmation, and typing over it is always allowed.
function rollBio(key) {
  const r = rules.rollBackground(key, { double: key === 'age' && S.longLived });
  if (!r || r.text == null) return;
  S.bio[key] = r.text;
  S.bioRolls[key] = r.roll;
  render();
}

// Fills only what is still blank, so a name and age already decided survive.
function rollBioAll() {
  for (const key of Object.keys(rules.BACKGROUND_TABLES)) {
    if (S.bio[key]) continue;
    rollBio(key);
  }
  render();
}

// Re-rolls the age when the multiplier changes, since the old value was rolled
// under the other assumption and leaving it would be quietly wrong.
function setLongLived(on) {
  S.longLived = !!on;
  if (S.bio.age) rollBio('age'); else render();
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
  // Powers and spells the CLASS grants outright, as opposed to the ones the
  // player picked. They used to reach the character as nothing at all: the
  // wizard saved only S.spells and S.psi, so a Mind Melter's four automatic
  // powers and a Shifter's twenty known spells were listed by the class and
  // held by nobody. Granted ones come first and a pick that duplicates one
  // is dropped, so the list stays a set.
  const cls = psiClass();
  const auto = (list) => (list || []).filter((n) => typeof n === 'string' && n.trim()).map((n) => n.trim());
  const autoSpells = auto(cls?.magic?.spells);
  const autoPsi = auto(cls?.psionics?.powers);
  const held = (a, b) => {
    const seen = new Set(a.map((n) => n.toLowerCase()));
    return [...a, ...b.filter((n) => !seen.has(String(n).toLowerCase()))];
  };
  const spellNames = held(autoSpells, S.spells);
  const psiNames = held(autoPsi, S.psi);
  return [
    ...spellNames.map((n) => {
      const sp = S.spellCatalog.find((x) => x.name === n);
      return { type: 'spell', name: n, level: sp?.level, cost: sp?.ppe,
               ...(sp?.ppe_note ? { cost_note: sp.ppe_note } : {}) };
    }),
    ...psiNames.map((n) => {
      const p = S.psiCatalog.find((x) => x.name === n);
      // cost_note marks a variable cost: `cost` is the minimum, and the sheet's
      // use button deducts it while the note says how the real spend grows.
      return { type: 'psionic', name: n, category: p?.category, cost: p?.isp,
               ...(p?.isp_note ? { cost_note: p.isp_note } : {}) };
    }),
  ];
}

// Step 6 — review & save
//
// A character's I.Q. adds a ONE-TIME bonus to every skill percentage (p.22).
// One-time is the operative word: it lands in the starting number and never
// again, which is why it is added here at creation rather than anywhere that
// runs per level.
//
// It reaches secondary skills too. The book's "no skill bonuses are applicable"
// is about the bonus printed in parentheses on the O.C.C. page — it says so in
// the same breath, "the bonus indicated in parentheses applies only to O.C.C.
// related skill selections". The I.Q. bonus is a separate paragraph about the
// character rather than the occupation, and withholding it would make a
// genius's hobby skills identical to a dullard's.
//
// A skill with no percentage at all — W.P.s, hand to hand — stays at zero. It
// is not a percentile skill, so there is nothing for a percentage bonus to
// modify, and giving it a number would invent a roll that does not exist.
const SKILL_PCT_CAP = 98;   // p.22: "there is always a margin for error"

function skillsPayload() {
  const find = (n) => skillByName().get(n)
    || (isLanguageName(n) ? { ...(skillByName().get(LANGUAGE_OTHER) || {}), name: n } : {});
  const occ = S.cls.skills?.occ_skills || [];
  const iq = derive.bio(S.attrs, null, derive.classBonuses(skillBonusClass(), 1, rolledAll())).iq_skill_bonus_pct || 0;

  // pct stays the true current percentage, because level-up increments it and
  // the sheet prints it. iq_bonus records how much of it came from I.Q. so the
  // number can explain itself rather than being unexplained arithmetic.
  const withIq = (row) => {
    if (!row.pct) return { ...row, iq_bonus: 0 };
    return { ...row, pct: Math.min(SKILL_PCT_CAP, row.pct + iq), iq_bonus: iq };
  };

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
    // Secondary skills get no O.C.C. bonus, but they are not frozen: "all
    // skills increase as the character grows in experience". Storing 0 here
    // stopped them advancing forever, so a level 10 character's hobby skills
    // sat at their level 1 values.
    ...S.secondary.map((n) => ({ name: n, category: find(n).category, pct: find(n).base || 0, per_level: find(n).per_level || 0, type: 'secondary' })),
  ].map(withIq);
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
    <p class="small">Alignment: ${S.bio.alignment
      ? `<b>${esc(S.bio.alignment)}</b>${rules.alignmentGroup(S.bio.alignment) ? ` <span class="muted">(${rules.alignmentGroup(S.bio.alignment)})</span>` : ''}`
      : '<span class="warn">not chosen — required, see Details</span>'}</p>

    <div class="review-stats">
      <div class="stat-col">
        <h4>Attributes</h4>
        ${ATTRS.map((a) => `<div class="stat-row"><span>${a}</span><b>${S.attrs[a] ?? '—'}</b></div>`).join('')}
      </div>
      <div class="stat-col">
        <h4>Pools <button class="btn btn-sm btn-ghost" onclick="computePools(true); render()">↻ reroll</button></h4>
        ${poolRow('H.P.', p.hp)}${poolRow('S.D.C.', p.sdc)}${poolRow('M.D.C.', p.mdc)}
        ${poolRow('P.P.E.', p.ppe)}${poolRow('I.S.P.', p.isp)}
        ${S.bio.money ? poolRow(rules.currencyLabel(S.system), S.bio.money) : ''}
        <p class="muted small" style="margin-top:6px">Rolled from the class formulas. Reroll if your GM lets you.</p>
      </div>
    </div>

    ${listSection('Skills', skillsPayload().map((s) => esc(s.name)
      + (s.pct ? ` <span class="muted">${s.pct}%</span>` : '')
      + (s.iq_bonus ? ` <span class="muted small">+${s.iq_bonus} I.Q.</span>` : '')))}
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
  // "ALL players must choose an alignment for their character" (p.23). Caught
  // here rather than server-side so it cannot retroactively lock the editing of
  // characters created before the field existed.
  if (!S.bio.alignment) {
    msg.textContent = 'Choose an alignment on the Details step — the book requires one, and there is no neutral.';
    return;
  }
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
      psychic_tier: S.psiRoll?.tier || undefined,
      psychic_shape: S.psiRoll?.tier ? (S.psiShape || undefined) : undefined,
      attributes: S.attrs, attribute_bonuses: S.attrBonuses,
      rolled_bonuses: S.rolledBonuses, abilities: S.abilities,
      skills: skillsPayload(), powers: powersPayload(), pools: S.pools,
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
//
// Anything reached through the delegated `change` listener above does NOT belong
// here — it is called from inside this module and needs no global. The four
// toggles used to be inline and three of them kept their entry after the move;
// `toggleGearPick`, written after it, never had one, which is the shape to copy.
Object.assign(window, {
  S, render, computePools, goStep, pickSystem, classMode, quizPick, pickClass,
  confirmClass, setMethod, setAllMethod, doRoll, rollAll, manualSet, pbAdj,
  doPsiRoll, skipPsiRoll, setPsiShape, setPsiCategory,
  rollBio, rollBioAll, setLongLived,
  rmEquip, addCatalog, addCustom, setBio, save, startOver,
  resumeDraft, dismissDraft, pickVariant, pickOcc, takeAbility, dropAbility,
});

boot();
