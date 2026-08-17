// Character sheet — stats, skills, powers, inventory, journal, level-up.
// Owner/GM see edit controls; the server enforces the same rules regardless.
// escHtml() comes from /shared/js/ui.js.
'use strict';

const ATTRS = ['IQ', 'ME', 'MA', 'PS', 'PP', 'PE', 'PB', 'Spd'];
const POOLS = [['hp', 'H.P.'], ['sdc', 'S.D.C.'], ['mdc', 'M.D.C.'], ['ppe', 'P.P.E.'], ['isp', 'I.S.P.']];
const POOL_LABELS = { hp_max: 'H.P. max', sdc_max: 'S.D.C. max', mdc_max: 'M.D.C. max', ppe_max: 'P.P.E. max', isp_max: 'I.S.P. max' };
const id = new URLSearchParams(location.search).get('id');

const C = { data: null, items: [], journal: [], catalog: [], cls: null, canWrite: false, isGm: false,
            proposal: null, nextThreshold: null,
            // Picker filter text, and the skill picks chosen so far. Both are
            // state rather than DOM so a re-render cannot discard them.
            invFilter: '', pickFilter: '', pickValues: {},
            // A proposed change of stage, awaiting confirmation.
            variantProposal: null };
const $ = (i) => document.getElementById(i);

// api() and errorDetails() come from js/api.js, loaded first as a classic script.
const jsonReq = (method, body) => ({ method, headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });

async function load() {
  try {
    const res = await api('characters/' + id);
    C.data = res.character; C.items = res.items; C.canWrite = res.can_write; C.isGm = res.is_gm;
    // Skill picks a level-up granted and nobody has spent yet.
    C.pendingPicks = res.pending_picks || [];
    C.pendingPicksTotal = res.pending_picks_total || 0;
    // The class comes with the character now, already resolved to this
    // character's variant and still returned when it has been retired. It used
    // to mean fetching every class and finding this one, which could not apply
    // a variant: applyVariant lives in parser.js, a module, and this file is a
    // classic script.
    C.cls = res.class || null;

    const [journal, catalog, catalogs] = await Promise.all([
      api(`journal?campaign_id=${C.data.campaign_id}&character_id=${id}&include_campaign=1`),
      api('items?system=' + encodeURIComponent(C.data.campaign_system)),
      // The skill picker needs the catalog to offer choices and to show what a
      // skill starts at. Parallel, so it costs nothing on a sheet with no picks.
      api('catalogs').catch(() => ({ skills: [] })),
    ]);
    C.journal = journal.entries; C.catalog = catalog.items;
    C.skillCatalog = catalogs.skills || [];
    // Kept so the sheet can say when it is showing fewer entries than exist,
    // rather than quietly ending the log at the page boundary.
    C.journalTotal = journal.total ?? journal.entries.length;
    render();
  } catch (err) {
    $('app').innerHTML = `<div class="panel"><p class="err">Failed to load: ${escHtml(err.message)}</p></div>`;
  }
}

function flash(text, isError) {
  const el = $('msg');
  if (el) { el.textContent = text; el.className = isError ? 'err small' : 'muted small'; }
}

// ─── small builders for the sheet's boxed idiom ───
const box = (title, body, extra = '') =>
  `<div class="box"><div class="box-title"><span>${title}</span>${extra}</div><div class="box-body">${body}</div></div>`;

const field = (label, value, dim) =>
  `<div class="field"><span class="lbl">${label}</span><span class="dots"></span>` +
  `<span class="val${dim ? ' dim' : ''}">${value}</span></div>`;

// side_effects / restrictions come off the class as free text or a list.
const advisory = (label, value) => {
  if (!value || (Array.isArray(value) && !value.length)) return '';
  const text = Array.isArray(value) ? value.map((v) => `• ${v}`).join('\n') : String(value);
  return `<div class="advisory"><b>${label}:</b> ${escHtml(text)}</div>`;
};

function render() {
  const c = C.data, w = C.canWrite;
  const skills = Array.isArray(c.skills) ? c.skills : [];
  const powers = Array.isArray(c.powers) ? c.powers : [];
  const byType = (t) => skills.filter((s) => s.type === t);

  // Skills carry +%/Lvl and % columns, as on the printed sheet.
  const skillBox = (title, list) => box(title, list.length ? `
    <div class="skill-head"><span>Skill</span><span style="text-align:right">+%/Lvl</span><span style="text-align:right">%</span></div>
    ${list.map((s) => `<div class="skill-row">
      <span>${escHtml(s.name)}${s.iq_bonus ? ` <span class="note-inline" title="Includes a one-time +${s.iq_bonus}% from I.Q.">+${s.iq_bonus} I.Q.</span>` : ''}</span>
      <span class="num">${s.per_level ? '+' + s.per_level : '—'}</span>
      <span class="num pct">${s.pct ? s.pct + '%' : '—'}</span>
      ${s.note ? `<span class="note">↳ ${escHtml(s.note)}</span>` : ''}
    </div>`).join('')}` : '<p class="muted small">None.</p>');

  const vitals = POOLS.map(([key, label]) => {
    const max = c[key + '_max'], cur = c[key + '_current'];
    if (max == null && cur == null) return '';
    const curHtml = w
      ? `<input type="number" id="stat-${key}" value="${cur ?? ''}"><b class="print-only">${cur ?? '—'}</b>`
      : `<b>${cur ?? '—'}</b>`;
    return `<div class="vital"><div class="lbl">${label}</div>
      <div class="val">${curHtml} <span class="max">/ ${max ?? '—'}</span></div></div>`;
  }).join('');

  const powerRows = powers.map((p, i) => {
    const pool = p.type === 'spell' ? 'ppe' : 'isp';
    const cost = typeof p.cost === 'number' ? p.cost : null;
    const kind = p.type === 'spell'
      ? (p.level != null ? `spell · L${p.level}` : 'spell')
      : (p.category ? `psionic · ${p.category}` : 'psionic');
    const useBtn = w && cost != null && c[pool + '_current'] != null
      ? `<button class="btn btn-sm btn-ghost noprint" onclick="usePower(${i})">⚡ use</button>` : '';
    return `<div class="power-row">
      <span>${escHtml(p.name)} <span class="muted small">${escHtml(kind)}</span></span>
      <span class="cost">${cost != null ? cost + (pool === 'ppe' ? ' P.P.E.' : ' I.S.P.') : '—'}</span>
      ${useBtn}
    </div>`;
  }).join('');

  const invRows = inventoryRowsHtml();

  const journalHtml = C.journal.map((e) => {
    const isCampaign = e.character_id == null;
    const mine = e.character_id == c.id;
    if (!isCampaign && !mine) return ''; // other party members' entries stay off this sheet
    return `<div class="entry ${isCampaign ? 'campaign' : ''}">
      <span class="tag ${isCampaign ? 'gm' : ''}">${isCampaign ? 'campaign' : 'character'}</span>
      <b>${escHtml(e.title || 'Untitled')}</b>
      <span class="muted small"> — ${escHtml(e.author_email)}${e.session_date ? ' · session ' + escHtml(e.session_date) : ''} · ${escHtml(e.created_at)}</span>
      <div class="body">${escHtml(e.body)}</div>
    </div>`;
  }).join('') || '<p class="muted small">No journal entries yet.</p>';

  // A log longer than one page ends at the boundary; say so rather than looking
  // like the campaign simply stopped there.
  const journalMore = C.journalTotal > C.journal.length
    ? `<p class="muted small noprint">Showing the ${C.journal.length} most recent of ${C.journalTotal} entries.</p>`
    : '';

  const invMatches = Picker.filter(C.catalog, C.invFilter);
  const catalogOpts = invMatches.map((it) => `<option value="${escHtml(it.slug)}">${escHtml(it.name)}</option>`).join('');

  const attrs = c.attributes || {};
  const cls = C.cls || {};
  // What the class grants by this character's level. Attribute bonuses are not
  // stored on the character — they are added on the way past, so `attributes`
  // stays the numbers that were actually rolled.
  const bonuses = derive.classBonuses(cls, c.level);
  const effAttrs = derive.effective(attrs, bonuses);
  const combatParts = derive.parts('combat', attrs, bonuses);
  const savesParts = derive.parts('saves', attrs, bonuses, cls.psionics?.type);

  const bio = derive.bio(attrs, c.bio, bonuses);
  const combat = derive.combat(attrs, c.combat, bonuses);
  // The class supplies the psychic tier, which only affects the psionic save
  // TARGET. A character with no psionics block is not psychic and gets 15+,
  // which is the right number for them anyway.
  const saves = derive.saves(attrs, c.saves, cls.psionics?.type, bonuses);
  const armorList = Array.isArray(c.armor) ? c.armor : [];

  // An editable field: an input for owner/GM, plain text otherwise. Values that
  // came from the attribute tables rather than being typed are marked, so it is
  // obvious what is calculated and what a human set.
  // Where a derived number came from, for the hover text. A folded-in bonus you
  // cannot account for is indistinguishable from a bug, so the split is always
  // available even though the sheet shows one number.
  const explain = (parts, key) => {
    const p = parts?.[key];
    if (!p) return 'Derived from attributes — type to override';
    const bits = [];
    if (p.attrs) bits.push(`${p.attrs > 0 ? '+' : ''}${p.attrs} from attributes`);
    if (p.from_class) bits.push(`${p.from_class > 0 ? '+' : ''}${p.from_class} from ${cls.name || 'the class'}`);
    if (!bits.length) return 'Derived from attributes — type to override';
    return `${bits.join(', ')} — type to override`;
  };

  const editField = (section, key, label, value, stored, opts = {}) => {
    const isDerived = derive.isDerived(stored, key);
    const suffix = opts.suffix || '';
    const why = isDerived ? explain(opts.parts, key) : 'Set manually';
    // A class contribution is worth seeing without hovering, so it is marked.
    const fromClass = isDerived && opts.parts?.[key]?.from_class ? ' class-boosted' : '';
    if (!w) {
      return `<div class="field"><span class="lbl">${label}</span><span class="dots"></span>
        <span class="val${isDerived ? ' dim' : ''}${fromClass}" title="${escHtml(why)}">${escHtml(String(value ?? '—'))}${suffix}</span></div>`;
    }
    return `<div class="field"><span class="lbl">${label}</span><span class="dots"></span>
      <span class="val">
        <input class="mini-in${isDerived ? ' derived' : ''}${fromClass}" data-sec="${section}" data-key="${key}"
          type="${opts.type || 'text'}" value="${escHtml(stored?.[key] ?? '')}"
          placeholder="${escHtml(String(value ?? ''))}" title="${escHtml(why)}">${suffix}
        <b class="print-only">${escHtml(String(value ?? '—'))}${suffix}</b>
      </span></div>`;
  };

  // Alignment is a closed set (p.23), so it gets a picker rather than a text
  // box. It is NOT enforced here: a character created before the field existed
  // has no alignment, and refusing to save one would make it uneditable until
  // somebody guessed what it used to be. The sheet says it is missing and
  // otherwise stays out of the way.
  const bioField = (key, label, bio, stored) => {
    if (key !== 'alignment') return editField('bio', key, label, bio[key], stored);
    const current = stored?.alignment ?? bio.alignment ?? '';
    const group = window.rules?.alignmentGroup(current);
    if (!w) {
      return `<div class="field"><span class="lbl">${label}</span><span class="dots"></span>
        <span class="val${current ? '' : ' dim'}">${escHtml(current || '—')}${group ? ` (${group})` : ''}</span></div>`;
    }
    return `<div class="field"><span class="lbl">${label}</span><span class="dots"></span>
      <span class="val">
        <select class="mini-in${current ? '' : ' derived'}" data-sec="bio" data-key="alignment"
          title="${current ? escHtml(group ? group + ' alignment' : 'Not one of the seven standard alignments') : 'No alignment set — the book requires one'}"
          >${window.rules.alignmentOptions(current)}</select>
        <b class="print-only">${escHtml(current || '—')}</b>
      </span></div>`;
  };

  const BIO_FIELDS = [
    ['race', 'Race'], ['true_name', 'True Name'], ['occupation', 'Occupation'],
    ['alignment', 'Alignment'], ['age', 'Age'], ['sex', 'Sex'],
    ['height', 'Height'], ['weight', 'Weight'],
    ['family_origin', 'Family Origin'], ['environment', 'Environment'],
    ['native_languages', 'Native Language(s)'], ['insanity', 'Insanity (if any)'],
    // Gold in Palladium, credits in Rifts. Labelled from the campaign's system
    // rather than fixed, so a Rifts sheet does not say "Gold".
    ['money', window.rules.currencyLabel(c.campaign_system)],
  ];
  const COMBAT_FIELDS = [
    ['attacks', '# of Attacks'], ['initiative', 'Initiative'], ['strike', 'Strike'],
    ['parry', 'Parry'], ['dodge', 'Dodge'], ['roll', 'Roll w/ Punch'],
    ['damage_bonus', 'Damage'], ['punch', 'Punch'], ['power_punch', 'Power Punch'],
    ['kick', 'Kick'], ['knockout', 'Knock Out'], ['critical', 'Critical'],
    ['pull_punch', 'Pull Punch'],
    ['run_yards_per_melee', 'Run (yds/melee)'],
  ];
  const SAVE_FIELDS = [
    ['spell_magic', 'vs Spell Magic'], ['ritual_magic', 'vs Ritual Magic'],
    ['psionics', 'vs Psionics'], ['toxins_poisons', 'vs Toxins/Poisons'],
    ['harmful_drugs', 'vs Harmful Drugs'], ['insanity', 'vs Insanity'],
    ['possession', 'vs Possession'], ['horror_factor', 'vs Horror Factor'],
    ['coma_death_pct', 'vs Coma/Death'], ['pain', 'vs Pain'],
    ['illusionary_magic', 'vs Illusionary Magic'], ['mind_control', 'vs Mind Control'],
  ];

  const armorRows = armorList.map((a, i) => armorSlotHtml(a, i, w)).join('');

  $('app').innerHTML = `
  ${box(`${escHtml(c.name)}${w ? '' : ' <span class="tag ro">read-only</span>'}${C.isGm ? ' <span class="tag gm">GM</span>' : ''}`, `
    <div class="sheet-grid cols-2">
      <div>
        ${field('O.C.C.', escHtml(cls.name || c.class_id))}
        ${field('Level', c.level)}
        ${field('Experience', `${c.xp} XP`)}
      </div>
      <div>
        ${field('Campaign', escHtml(c.campaign_name), true)}
        ${field('System', escHtml(c.campaign_system), true)}
        ${field('Player', escHtml(c.player_email), true)}
      </div>
    </div>
    <div class="sheet-grid cols-2" style="margin-top:6px">
      <div>${BIO_FIELDS.slice(0, 7).map(([k, l]) => bioField(k, l, bio, c.bio)).join('')}</div>
      <div>${BIO_FIELDS.slice(7).map(([k, l]) => bioField(k, l, bio, c.bio)).join('')}</div>
    </div>
    <div class="sheet-grid cols-2">
      <div>${editField('bio', 'invoke_trust_pct', 'Invoke Trust/Intimidate', bio.invoke_trust_pct, c.bio, { suffix: '%' })}</div>
      <div>${editField('bio', 'charm_impress_pct', 'Charm/Impress', bio.charm_impress_pct, c.bio, { suffix: '%' })}</div>
    </div>`)}

  <div class="sheet-grid rail" style="margin-top:12px">
    ${box('Attributes', `<div class="attr-stack">
      ${ATTRS.map((a) => {
        const add = bonuses.attributes[a];
        // The stored attribute is what was rolled; the class bonus rides
        // alongside it so both stay legible, and effAttrs is what the tables read.
        return field(a, attrs[a] == null ? '—'
          : add ? `${attrs[a]} <span class="attr-bonus" title="${escHtml(`${add > 0 ? '+' : ''}${add} from ${cls.name || 'the class'}`)}">${add > 0 ? '+' : ''}${add}</span> = ${effAttrs[a]}`
          : attrs[a]);
      }).join('')}
    </div>`)}

    ${box('Vitals', `<div class="vitals">${vitals || '<span class="muted small">None recorded.</span>'}</div>
      ${w ? `<div class="rowline noprint" style="margin-top:8px">
        <button class="btn btn-sm btn-primary" onclick="saveStats()">Save</button><span id="msg"></span></div>` : ''}`,
      '<span class="muted" style="font-size:9px">CURRENT / MAX</span>')}

    ${box('Experience', `
      ${field('Level', c.level)}
      ${field('Points', c.xp)}
      ${C.nextThreshold != null ? field('Next level at', `${C.nextThreshold} XP`, true) : ''}
      ${w ? `<div class="rowline noprint" style="margin-top:6px">
        <input type="number" id="xp-delta" placeholder="+XP" style="width:78px">
        <button class="btn btn-sm" onclick="logXp()">Log XP</button></div>` : ''}`)}

    ${w && !C.variantProposal ? variantPanel() : ''}
  </div>

  ${w && C.proposal ? levelUpPanel() : ''}
  ${w && C.variantProposal ? variantProposalPanel() : ''}
  ${w && !C.proposal && C.pendingPicksTotal ? pendingPicksPanel() : ''}

  <div class="sheet-grid rail" style="margin-top:12px">
    ${box('Saving Throws',
      // The psionic save target is what you roll against; the rest of this box
      // is bonuses. It sits at the top because it is the only absolute number
      // here, and it is overridable like everything else.
      // Suffix kept to one character: this column is narrow and anything longer
      // clips. The tier that produced the number goes in the label instead.
      editField('saves',
        'psionics_target',
        `vs Psionics — roll${cls.psionics?.type ? ` (${escHtml(cls.psionics.type)})` : ''}`,
        saves.psionics_target, c.saves, { suffix: '+' }) +
      SAVE_FIELDS.map(([k, l]) =>
      editField('saves', k, l, saves[k], c.saves, { suffix: k === 'coma_death_pct' ? '%' : '', parts: savesParts })).join(''),
      '<span class="muted" style="font-size:9px">DERIVED · OVERRIDABLE</span>')}

    ${box('Combat', COMBAT_FIELDS.map(([k, l]) =>
      editField('combat', k, l, combat[k], c.combat, { parts: combatParts })).join(''))}

    ${box('Armor', `<div id="armor-list">${armorRows}</div>` +
      (armorRows ? '' : '<p class="muted small" id="armor-empty">No armor recorded.</p>') +
      (w ? `<div class="rowline noprint" style="margin-top:8px">
        <button class="btn btn-sm" onclick="addArmor()">+ Add armor</button></div>` : ''))}
  </div>

  <div class="sheet-grid cols-3" style="margin-top:12px">
    ${skillBox('Class Skills', byType('occ'))}
    ${skillBox('Related Skills', byType('related'))}
    ${skillBox('Secondary Skills', byType('secondary'))}
  </div>

  <div class="sheet-grid cols-2" style="margin-top:12px">
    ${box('Psionics &amp; Magic', powers.length
      ? powerRows
      : '<p class="muted small">None.</p>')}

    ${box('Equipment', `
      <table><thead><tr><th>Item</th><th>Qty</th><th>Eq</th><th>Notes</th><th></th></tr></thead>
        <tbody id="inv-rows">${invRows || '<tr><td class="muted" colspan="5">Empty.</td></tr>'}</tbody></table>
      ${w ? `<div class="noprint" style="margin-top:8px">
        ${C.catalog.length ? Picker.inputHtml({ id: 'inv-filter', value: C.invFilter,
          placeholder: 'Filter catalog by name, category or book…',
          shown: invMatches.length, total: C.catalog.length }) : ''}
        <div class="rowline">
          ${C.catalog.length ? `<select id="add-slug"><option value="">— catalog —</option>${catalogOpts}</select>` : ''}
          <input type="text" id="add-name" placeholder="or custom item">
          <input type="number" id="add-qty" value="1" min="1">
        </div>
        <div class="rowline">
          <input type="text" id="add-notes" placeholder="Notes (optional)" style="width:150px">
          <label class="small"><input type="checkbox" id="add-log"> log it</label>
          <button class="btn btn-sm" onclick="addItem()">Add</button>
        </div></div>` : ''}`)}
  </div>

  <div class="sheet-grid cols-2" style="margin-top:12px">
    ${box('Notes', `
      ${w ? `<textarea id="stat-notes" class="noprint">${escHtml(c.notes || '')}</textarea>
             <p class="print-only small" style="white-space:pre-wrap">${escHtml(c.notes || '—')}</p>`
          : `<p class="small" style="white-space:pre-wrap">${escHtml(c.notes || '—')}</p>`}
      ${advisory('Side effects', cls.side_effects)}
      ${advisory('Restrictions', cls.restrictions)}
      ${C.cls?._retired
        ? advisory('Retired class', 'This class has been retired and can no longer be chosen for new characters. This character is unaffected.')
        : ''}`)}

    ${box('Journal', `
      ${w ? `<div class="noprint">
        <div class="rowline">
          <input type="text" id="j-title" placeholder="Title">
          <input type="text" id="j-date" placeholder="Session date" style="width:120px">
          ${C.isGm ? `<label class="small"><input type="checkbox" id="j-campaign"> campaign</label>` : ''}
        </div>
        <textarea id="j-body" placeholder="What happened this session…"></textarea>
        <div class="rowline"><button class="btn btn-sm" onclick="addJournal()">Add entry</button></div>
      </div>` : ''}
      <div id="journal-list">${journalHtml}</div>
      ${journalMore}`,
      '<span class="muted" style="font-size:9px">NEWEST FIRST</span>')}
  </div>`;

  wirePickers();
}

// Filter inputs are destroyed and rebuilt by every render, so their listeners
// are re-bound here. Picker.wire restores the caret, which a delegated listener
// could not do.
function wirePickers() {
  Picker.wire('inv-filter', { onInput: (v) => { C.invFilter = v; render(); } });
  for (const el of document.querySelectorAll('[id$="-pick-filter"]')) {
    Picker.wire(el.id, { onInput: (v) => { C.pickFilter = v; render(); } });
  }
}

function levelUpPanel() {
  const p = C.proposal;
  const poolRows = Object.entries(p.pools).map(([field, v]) =>
    `<tr><td>${POOL_LABELS[field]}</td><td>${v.from}</td>
     <td>→ <input type="number" id="lu-${field}" value="${v.to}"></td></tr>`).join('');
  const skillRows = p.skills.map((s, i) =>
    `<tr><td>${escHtml(s.name)} <span class="muted small">(${escHtml(s.type)})</span></td><td>${s.from}%</td>
     <td>→ <input type="number" id="lu-skill-${i}" value="${s.to}">%</td></tr>`).join('');
  const grants = p.grants.map((g) =>
    `<li class="small">Level ${g.level}: ${g.grants.map(escHtml).join('; ')}</li>`).join('');
  return `
  <div class="levelup noprint">
    <h3 style="margin-top:0">⬆ Level up! ${p.from_level} → ${p.to_level}
      <span class="muted small">— review, tweak if your GM says so, then confirm</span></h3>
    <table>${poolRows}${skillRows}</table>
    ${grants ? `<h3>New abilities</h3><ul style="margin-left:18px">${grants}</ul>` : ''}
    ${p.skill_picks_total ? pickerBlock(p.skill_picks, p.skill_picks_total, 'lu') : ''}
    <div class="rowline" style="margin-top:10px">
      <button class="btn btn-primary" onclick="confirmLevelUp()">✅ Confirm level-up</button>
      <button class="btn btn-sm btn-ghost" onclick="C.proposal=null; render()">Not now</button>
      <span class="muted small">Nothing is applied until you confirm.</span>
    </div>
  </div>`;
}

// Picks earned at a level-up and skipped. Shown until they are spent, so a
// banked grant does not quietly disappear from view.
function pendingPicksPanel() {
  const n = C.pendingPicksTotal;
  if (!C.claiming) {
    return `
    <div class="levelup noprint">
      <h3 style="margin-top:0">🎓 ${n} unspent skill pick${n > 1 ? 's' : ''}
        <span class="muted small">— earned at ${C.pendingPicks.map((g) => 'level ' + g.granted_at_level).join(', ')}</span></h3>
      <button class="btn" onclick="C.claiming = true; render()">Choose now</button>
    </div>`;
  }
  return `
  <div class="levelup noprint">
    ${pickerBlock(C.pendingPicks.map((g) => ({ level: g.granted_at_level, count: g.count, categories: g.categories })), n, 'claim')}
    <div class="rowline" style="margin-top:10px">
      <button class="btn btn-primary" onclick="claimPicks()">Add to sheet</button>
      <button class="btn btn-sm btn-ghost" onclick="C.claiming = false; C.pickShowAll = false; C.pickFilter = ''; C.pickValues = {}; render()">Later</button>
    </div>
  </div>`;
}

// Shared by the level-up panel and the standalone claim on the sheet, so the
// two ways of spending a pick look and behave the same.
//
// Skipping is deliberately free: the picks are banked either way, so nobody is
// stuck at the table choosing skills before they can carry on playing.
function pickerBlock(grants, total, prefix) {
  const allowed = grants.some((g) => !g.categories)
    ? null
    : [...new Set(grants.flatMap((g) => g.categories || []))];

  const held = new Set((C.data.skills || []).map((s) => s.name));
  const showAll = C.pickShowAll;
  const pool = (C.skillCatalog || [])
    .filter((s) => !held.has(s.name))
    .filter((s) => showAll || !allowed || allowed.includes(s.category));

  // One filter feeding every dropdown in the block, because they draw from one
  // pool — you are picking N different skills out of the same 128, not
  // searching N times. Narrowing them together is what you actually want.
  const shown = Picker.filter(pool, C.pickFilter);
  const options = shown
    .map((s) => `<option value="${escHtml(s.name)}">${escHtml(s.name)} — ${escHtml(s.category || '?')} ${s.base}%</option>`)
    .join('');

  const hiddenCount = allowed && !showAll
    ? (C.skillCatalog || []).filter((s) => !held.has(s.name) && !allowed.includes(s.category)).length
    : 0;

  // Selections live in state, not in the DOM. They used to be read off the
  // <select>s only at submit time, so any re-render in between silently threw
  // them away — the "show all skills" checkbox already did that, and a filter
  // that re-renders on every keystroke would do it constantly.
  const rows = Array.from({ length: total }, (_, i) => {
    const chosen = C.pickValues[`${prefix}-${i}`] || '';
    // A skill you have already chosen stays in its own dropdown even when the
    // filter excludes it, or narrowing the list would un-pick it.
    const extra = chosen && !shown.some((s) => s.name === chosen)
      ? `<option value="${escHtml(chosen)}" selected>${escHtml(chosen)}</option>` : '';
    const opts = options.replace(`value="${escHtml(chosen)}"`, `value="${escHtml(chosen)}" selected`);
    return `
    <div class="rowline">
      <select id="${prefix}-pick-${i}" onchange="C.pickValues['${prefix}-${i}'] = this.value">
        <option value="">— skip —</option>${extra}${chosen ? opts : options}</select>
    </div>`;
  }).join('');

  return `
  <h3 style="margin-bottom:4px">New skill${total > 1 ? 's' : ''} — ${total} to choose</h3>
  <p class="muted small" style="margin-top:0">
    ${grants.map((g) => `${g.count} from level ${g.level}`).join(', ')}.
    New skills start at their base percentage. Leave any blank and it waits on your sheet.</p>
  ${Picker.inputHtml({ id: `${prefix}-pick-filter`, value: C.pickFilter,
    placeholder: 'Filter skills…', shown: shown.length, total: pool.length })}
  ${rows}
  ${hiddenCount ? `<label class="inline-check small">
    <input type="checkbox" ${showAll ? 'checked' : ''} onchange="C.pickShowAll = this.checked; render()">
    show all skills (${hiddenCount} outside this grant's categories — picking one is flagged as an override)
  </label>` : ''}`;
}

// Collect whatever the picker selected. A blank stays unspent.
function collectPicks(prefix, total) {
  const picks = [];
  for (let i = 0; i < total; i++) {
    // State first, DOM as the fallback — they agree, but state is the one that
    // survives a re-render.
    const v = C.pickValues[`${prefix}-${i}`] ?? $(`${prefix}-pick-${i}`)?.value;
    if (v) picks.push({ name: v, override: !!C.pickShowAll });
  }
  return picks;
}

async function logXp() {
  const delta = parseInt($('xp-delta').value, 10);
  if (!Number.isFinite(delta)) { alert('Enter an XP amount (0 re-checks for a pending level-up).'); return; }
  try {
    const res = await api(`characters/${id}/xp`, jsonReq('POST', { delta }));
    C.data.xp = res.xp;
    C.nextThreshold = res.next_threshold;
    C.proposal = res.proposal;
    render();
  } catch (err) { alert('XP update failed: ' + err.message); }
}

async function confirmLevelUp() {
  const p = C.proposal;
  const pools = {};
  for (const field of Object.keys(p.pools)) {
    const v = parseInt($('lu-' + field).value, 10);
    if (Number.isFinite(v)) pools[field] = v;
  }
  const skills = p.skills.map((s, i) => {
    const v = parseInt($('lu-skill-' + i).value, 10);
    return { name: s.name, pct: Number.isFinite(v) ? v : s.to };
  });
  const picks = p.skill_picks_total ? collectPicks('lu', p.skill_picks_total) : [];
  try {
    await api(`characters/${id}/level-confirm`, jsonReq('POST', {
      to_level: p.to_level, pools, skills, grants: p.grants, picks,
    }));
    C.proposal = null;
    C.pickShowAll = false;
    C.pickFilter = ''; C.pickValues = {};
    await load();
  } catch (err) {
    const details = errorDetails(err);
    alert(['Level-up failed: ' + err.message, ...details.map((d) => '- ' + d)].join('\n'));
  }
}

// Picks banked from an earlier level-up, spent whenever the player comes back.
async function claimPicks() {
  const total = C.pendingPicksTotal;
  const picks = collectPicks('claim', total);
  if (!picks.length) { flash('Choose at least one skill, or leave it for later.', true); return; }
  try {
    const res = await api(`characters/${id}/picks`, jsonReq('POST', { picks }));
    C.pickShowAll = false;
    C.pickFilter = ''; C.pickValues = {};
    C.claiming = false;
    await load();
    flash(`Added ${res.applied.map((a) => a.name).join(', ')}.`);
  } catch (err) { flash('Could not add: ' + err.message, true); }
}

// Spend PPE/ISP on a power — client-side arithmetic + the existing PATCH
// endpoint (server still enforces owner/GM on the PATCH itself).
async function usePower(index) {
  const p = (C.data.powers || [])[index];
  if (!p || typeof p.cost !== 'number') return;
  const pool = p.type === 'spell' ? 'ppe' : 'isp';
  const cur = C.data[pool + '_current'];
  if (cur == null) return;
  if (cur < p.cost) { alert(`Not enough ${pool === 'ppe' ? 'P.P.E.' : 'I.S.P.'} (${cur} left, ${p.name} costs ${p.cost}).`); return; }
  try {
    await api('characters/' + id, jsonReq('PATCH', { [pool + '_current']: cur - p.cost }));
    await load();
  } catch (err) { alert('Failed: ' + err.message); }
}

// One armour slot. Hoisted out of render() so addArmor can append a slot
// without rebuilding the page around it.
const ARMOR_KEYS = ['ar', 'mdc_current', 'mdc_max', 'weight', 'cost', 'prowl'];
const ARMOR_LABELS = { ar: 'A.R.', mdc_current: 'M.D.C.', mdc_max: 'of',
                       weight: 'Weight', cost: 'Cost', prowl: 'Prowl' };

function armorSlotHtml(a, i, w) {
  return `
    <div class="armor-slot">
      <div class="field"><span class="lbl">Armor</span><span class="dots"></span>
        <span class="val">${w ? `<input class="mini-in wide" data-armor="${i}" data-key="name" value="${escHtml(a.name ?? '')}">` : escHtml(a.name || '—')}</span></div>
      <div class="armor-stats">
        ${ARMOR_KEYS.map((k) => `
          <div class="field"><span class="lbl">${ARMOR_LABELS[k]}</span>
            <span class="val">${w ? `<input class="mini-in" data-armor="${i}" data-key="${k}" value="${escHtml(a[k] ?? '')}">` : escHtml(String(a[k] ?? '—'))}</span></div>`).join('')}
      </div>
      ${w ? `<button class="btn btn-sm btn-ghost noprint" data-armor-remove="${i}" onclick="removeArmor(+this.dataset.armorRemove)">Remove</button>` : ''}
    </div>`;
}

// The inventory table's rows. Hoisted for the same reason: an item change
// re-renders this and nothing else.
function inventoryRowsHtml() {
  const w = C.canWrite;
  return C.items.map((it) => {
    const name = escHtml(it.item_name || it.custom_name);
    const kind = it.item_id ? '<span class="tag">catalog</span>' : '<span class="tag">custom</span>';
    const qty = w
      ? `<input type="number" min="1" value="${it.qty}" onchange="patchItem(${it.id}, {qty: this.value})"><span class="print-only">×${it.qty}</span>`
      : `×${it.qty}`;
    const eq = w
      ? `<input type="checkbox" ${it.equipped ? 'checked' : ''} onchange="patchItem(${it.id}, {equipped: this.checked})"><span class="print-only">${it.equipped ? '✔' : '—'}</span>`
      : (it.equipped ? '✔' : '');
    const rm = w ? `<td><button class="btn btn-sm btn-ghost" onclick="removeItem(${it.id})">✕</button></td>` : '<td></td>';
    return `<tr><td>${name} ${kind}</td><td>${qty}</td><td>${eq}</td>
      <td class="muted small">${escHtml(it.notes || '')}</td>${rm}</tr>`;
  }).join('');
}

// Refresh the inventory from the server and repaint only that table.
//
// These used to call load(), which refetches the character and replaces C.data
// wholesale — so adding an item silently discarded anything typed into the
// combat, saves or bio fields. keepEdits() could not help, because load()
// overwrote the state it had just saved.
async function refreshInventory() {
  const res = await api('characters/' + id);
  C.items = res.items;
  const body = $('inv-rows');
  if (body) {
    body.innerHTML = inventoryRowsHtml() || '<tr><td class="muted" colspan="5">Empty.</td></tr>';
  }
}

// ─── targeted updates ───
//
// The sheet used to re-render wholly on every edit, which discarded whatever
// was typed into the other inputs. keepEdits() existed to collect and restore
// them — a patch around the architecture rather than a fix, and one that every
// new interactive block had to remember to participate in.
//
// These two paths update in place instead. Nothing else is touched, so unsaved
// edits elsewhere simply survive: the DOM is the source of truth for them until
// Save reads it back with collectSections().
//
// Everything else — load, save, level-up, switching character — still does a
// full render. Correctness over cleverness.

function addArmor() {
  const list = $('armor-list');
  if (!list) return;
  const i = list.querySelectorAll('.armor-slot').length;
  list.insertAdjacentHTML('beforeend', armorSlotHtml({ name: '' }, i, C.canWrite));
  $('armor-empty')?.remove();
}

function removeArmor(i) {
  const list = $('armor-list');
  const slot = list?.querySelectorAll('.armor-slot')[i];
  if (!slot) return;
  slot.remove();
  // collectSections() reads data-armor as an array index, so the slots after
  // the removed one have to close the gap.
  reindexArmor();
}

function reindexArmor() {
  const slots = $('armor-list')?.querySelectorAll('.armor-slot') || [];
  slots.forEach((slot, i) => {
    for (const input of slot.querySelectorAll('input[data-armor]')) input.dataset.armor = i;
    const btn = slot.querySelector('button[data-armor-remove]');
    if (btn) btn.dataset.armorRemove = i;
  });
}

// Reads the section inputs back out of the DOM. Blank means "no override" —
// the value falls back to the derived default rather than being stored as 0.
function collectSections() {
  const out = { bio: {}, combat: {}, saves: {} };
  // Selects as well as inputs: alignment is a picker, and matching only
  // `input[data-sec]` would drop it on every save without saying so.
  for (const el of document.querySelectorAll('input[data-sec], select[data-sec]')) {
    const v = el.value.trim();
    if (v !== '') out[el.dataset.sec][el.dataset.key] = v;
  }
  const armor = [];
  for (const el of document.querySelectorAll('input[data-armor]')) {
    const i = +el.dataset.armor;
    (armor[i] ||= {})[el.dataset.key] = el.value.trim();
  }
  out.armor = armor.filter((a) => a && Object.values(a).some((v) => v !== ''));
  return out;
}

async function saveStats() {
  const body = { notes: $('stat-notes').value, ...collectSections() };
  for (const [key] of POOLS) {
    const el = $('stat-' + key);
    if (el) body[key + '_current'] = el.value === '' ? null : +el.value;
  }
  try {
    await api('characters/' + id, jsonReq('PATCH', body));
    flash('Saved.');
    await load();
  } catch (err) {
    const details = errorDetails(err);
    flash('Save failed: ' + err.message + (details.length ? ' — ' + details.join('; ') : ''), true);
  }
}

async function patchItem(rowId, fields) {
  try { await api(`characters/${id}/items/${rowId}`, jsonReq('PATCH', fields)); await refreshInventory(); }
  catch (err) { alert('Update failed: ' + err.message); }
}

async function removeItem(rowId) {
  if (!confirm('Remove this item from inventory? (History is kept.)')) return;
  try { await api(`characters/${id}/items/${rowId}`, { method: 'DELETE' }); await refreshInventory(); }
  catch (err) { alert('Remove failed: ' + err.message); }
}

async function addItem() {
  const slug = $('add-slug')?.value || null;
  const name = $('add-name').value.trim();
  const qty = Math.max(1, +$('add-qty').value || 1);
  const notes = $('add-notes').value.trim() || null;
  if (!slug && !name) { alert('Pick a catalog item or enter a name.'); return; }
  try {
    let journalId = null;
    if ($('add-log').checked) {
      const label = slug ? C.catalog.find((i) => i.slug === slug)?.name : name;
      const entry = await api('journal', jsonReq('POST', {
        character_id: +id, title: 'Inventory: ' + label,
        body: `Acquired ${label}${qty > 1 ? ' ×' + qty : ''}${notes ? ' — ' + notes : ''}`,
      }));
      journalId = entry.entry.id;
    }
    await api(`characters/${id}/items`, jsonReq('POST', {
      slug, custom_name: slug ? null : name, qty, notes, journal_entry_id: journalId,
    }));
    await load();
  } catch (err) { alert('Add failed: ' + err.message); }
}

async function addJournal() {
  const body = $('j-body').value.trim();
  if (!body) { alert('Write something first.'); return; }
  const campaignLevel = $('j-campaign')?.checked;
  try {
    await api('journal', jsonReq('POST', {
      character_id: campaignLevel ? null : +id,
      campaign_id: C.data.campaign_id,
      title: $('j-title').value.trim() || null,
      session_date: $('j-date').value.trim() || null,
      body,
    }));
    await load();
  } catch (err) { alert('Journal failed: ' + err.message); }
}

if (!id) {
  $('app').innerHTML = '<div class="panel"><p class="err">No character id — open a sheet from the character list.</p></div>';
} else {
  load();
}

// ─── changing stage ───
//
// A hatchling grows into an adult. Two-step for the same reason a level-up is:
// the rolls are the point, and a roll you did not watch happen is a roll you
// cannot trust. Old sits beside new and you take each one or keep what you had.

function variantPanel() {
  const variants = C.cls?.variants || [];
  if (!variants.length) return '';
  const current = C.data.class_variant;
  const options = variants.filter((v) => v.id !== current);
  if (!options.length) return '';

  return `<div class="box noprint">
    <div class="box-title"><span>Stage</span></div>
    <div class="box-body">
      <p class="muted small" style="margin:0 0 6px">
        Currently <b>${escHtml(C.cls.name)}</b>. Changing stage re-rolls only what the new
        stage actually sets, and nothing is applied until you confirm.</p>
      <div class="rowline">
        <select id="variant-to">
          ${options.map((v) => `<option value="${escHtml(v.id)}">${escHtml(v.name || v.id)}</option>`).join('')}
        </select>
        <button class="btn btn-sm" onclick="proposeVariant()">Preview the change</button>
      </div>
    </div>
  </div>`;
}

function variantProposalPanel() {
  const p = C.variantProposal;
  if (!p) return '';

  const attrRows = Object.entries(p.attributes).map(([a, v]) => `
    <tr>
      <td><b>${a}</b> <span class="muted small">${escHtml(v.dice)}</span></td>
      <td>${v.from ?? '—'}</td>
      <td>→ <input type="number" id="vc-attr-${a}" value="${v.rolled}"></td>
      <td><label class="inline-check small">
        <input type="checkbox" id="vc-keep-${a}"> keep ${v.from ?? '—'}</label></td>
    </tr>`).join('');

  const poolRows = Object.entries(p.pools).map(([pool, v]) => `
    <tr>
      <td>${POOL_LABELS[pool + '_max'] || pool} <span class="muted small">${escHtml(v.formula)}</span></td>
      <td>${v.from_max}</td>
      <td>→ <input type="number" id="vc-pool-${pool}" value="${v.rolled_max}"></td>
      <td class="muted small">current moves by the same amount</td>
    </tr>`).join('');

  const nothing = !attrRows && !poolRows;
  return `
  <div class="levelup noprint">
    <h3 style="margin-top:0">${escHtml(p.from_name || 'Current')} → ${escHtml(p.to_name)}</h3>
    ${nothing
      ? `<p class="small">This stage sets no different dice or pools — only what the class grants
         changes, and that applies as soon as the stage does.</p>`
      : `<table>${attrRows}${poolRows}</table>
         <p class="muted small">Only the attributes this stage actually specifies are offered.
         Tick <em>keep</em> to hold the number you already had.</p>`}
    <div class="rowline" style="margin-top:10px">
      <button class="btn btn-primary" onclick="confirmVariant()">✅ Confirm the change</button>
      <button class="btn btn-sm btn-ghost" onclick="C.variantProposal=null; render()">Not now</button>
      <span class="muted small">Nothing is applied until you confirm.</span>
    </div>
  </div>`;
}

async function proposeVariant() {
  const to = $('variant-to')?.value;
  if (!to) return;
  try {
    const res = await api(`characters/${id}/variant`, jsonReq('POST', { to_variant: to }));
    C.variantProposal = res.proposal;
    render();
  } catch (err) { flash(err.message, true); }
}

async function confirmVariant() {
  const p = C.variantProposal;
  if (!p) return;
  // A ticked "keep" simply omits the attribute, which leaves it untouched.
  const attributes = {};
  for (const a of Object.keys(p.attributes)) {
    if ($(`vc-keep-${a}`)?.checked) continue;
    const v = parseInt($(`vc-attr-${a}`)?.value, 10);
    if (Number.isFinite(v)) attributes[a] = v;
  }
  const pools = {};
  for (const pool of Object.keys(p.pools)) {
    const v = parseInt($(`vc-pool-${pool}`)?.value, 10);
    if (Number.isFinite(v)) pools[pool] = v;
  }
  try {
    const res = await api(`characters/${id}/variant`,
      jsonReq('POST', { to_variant: p.to_variant, confirm: true, attributes, pools }));
    C.variantProposal = null;
    flash(`Now ${res.name}.`);
    await load();
  } catch (err) { flash(err.message, true); }
}
