// Character sheet — stats, skills, powers, inventory, journal, level-up.
// Owner/GM see edit controls; the server enforces the same rules regardless.
// escHtml() comes from /shared/js/ui.js.
'use strict';

const ATTRS = ['IQ', 'ME', 'MA', 'PS', 'PP', 'PE', 'PB', 'Spd'];
const POOLS = [['hp', 'H.P.'], ['sdc', 'S.D.C.'], ['mdc', 'M.D.C.'], ['ppe', 'P.P.E.'], ['isp', 'I.S.P.']];
const POOL_LABELS = { hp_max: 'H.P. max', sdc_max: 'S.D.C. max', mdc_max: 'M.D.C. max', ppe_max: 'P.P.E. max', isp_max: 'I.S.P. max' };
// Every save derive.js produces, in the order the sheet prints them. ONE list,
// because there were two: the sheet's carried all thirteen and play mode's
// carried the first eight, so a Juicer's +6 vs mind control, an adult
// Chiang-Ku's +3 vs illusionary magic and a Ley Line Walker's +3 vs curses were
// all on the sheet and none of them was rollable at the table. The second list
// was not a shorter view chosen on purpose - it was the first list before three
// keys were added to derive.js and only one copy was updated.
const SAVE_FIELDS = [
  ['spell_magic', 'vs Spell Magic'], ['ritual_magic', 'vs Ritual Magic'],
  ['psionics', 'vs Psionics'], ['toxins_poisons', 'vs Toxins/Poisons'],
  ['harmful_drugs', 'vs Harmful Drugs'], ['insanity', 'vs Insanity'],
  ['possession', 'vs Possession'], ['horror_factor', 'vs Horror Factor'],
  ['coma_death_pct', 'vs Coma/Death'], ['pain', 'vs Pain'],
  ['illusionary_magic', 'vs Illusionary Magic'], ['mind_control', 'vs Mind Control'],
  ['curses', 'vs Curses'], ['faerie_magic', 'vs Faerie Magic'],
  ['disease', 'vs Disease'], ['fatigue', 'vs Fatigue'],
];
// Play mode rolls a d20, so the one percentile row is not one of its buttons.
// Filtered rather than listed again, which is how the two drifted the first time.
const SAVE_ROLLS = SAVE_FIELDS.filter(([key]) => !key.endsWith('_pct'));
// The combat rows play mode offers a die on: the four the old play view drew as
// .play-roll buttons, and no more. Attacks per melee, damage bonuses and Run
// are numbers you READ mid-fight rather than d20 rolls, and a die beside them
// would invite a roll that means nothing. A Set rather than a second list of
// labels, so it is keyed off COMBAT_FIELDS' own keys and cannot drift from
// them the way SAVE_ROLLS was written to avoid.
const ROLLABLE_COMBAT = new Set(['initiative', 'strike', 'parry', 'dodge']);

// The saves a book states that the sixteen fields above do not name
// (BOOK-INGEST-AUDIT.md F7) — the Spacer's "+2 to any saves against explosive
// decompression or other space dangers" being the case that filed it.
//
// Read straight off the class, not out of the derived saves map. These carry no
// attribute chart and nothing to override, so there is no derived value for a
// stored one to win over; they are what the book printed and that is all.
// Defensive about shape because a class row is data, not a contract.
function otherSaves(cls) {
  const list = cls?.bonuses?.saves?.other;
  if (!Array.isArray(list)) return [];
  return list.filter((e) => e && typeof e === 'object'
    && typeof e.label === 'string' && e.label.trim()
    && Number.isFinite(Number(e.bonus)) && Number(e.bonus) !== 0);
}

const id = new URLSearchParams(location.search).get('id');

const C = { data: null, items: [], journal: [], catalog: [], cls: null, canWrite: false, isGm: false, conflicts: {},
  // Clashes the player has ALREADY answered, by queue seq. They leave
  // `conflicts` the moment they are answered so the pool card stops offering
  // the choice, and wait here until the rest of the same press is answered too.
            resolved: {},
  // What the character's Hand to Hand training grants in words, by level.
            skillLevelNotes: [], weaponBonuses: [],
            proposal: null, nextThreshold: null,
            // Picker filter text, and the skill picks chosen so far. Both are
            // state rather than DOM so a re-render cannot discard them.
            invFilter: '', pickFilter: '', skillFilter: '', pickValues: {}, pickLangs: {},
            // Held power descriptions, and which of them are open. State for
            // the same reason as the filters above: the use button re-renders.
            powerDescriptions: {}, openPowerDescs: new Set(), openItemDescs: new Set(),
            vehicles: [], openVessels: new Set(), vesselCatalog: null,
            // Play mode: the same data through an action-first, phone-shaped
            // lens. playAmt is the selected quick-action amount; rollLog is
            // structured from day one, and phase 3 persists it unchanged.
            playMode: new URLSearchParams(location.search).get('play') === '1',
            playAmt: 1, lastRoll: null, rollLog: [],
            // Rolls that never reached the log. Not a queue - see persistRoll.
            rollsNotLogged: 0,
            // A proposed change of stage, awaiting confirmation.
            variantProposal: null,
            // What a table handed this character outside its class schedule.
            // The granted SKILLS are already in `data.skills` as type 'gm';
            // these rows are what say who gave them and why.
            grants: [] };
const $ = (i) => document.getElementById(i);

// Presentation lives in js/sheet-layout.js - the pool widget, the box and
// field helpers, and the table that decides a box's column. Destructured
// here so this file's call sites read exactly as they did before the split.
const { POOL_TONES, POOL_LOW, poolCard, boxSlug, BOX_COL, box, field,
  trackableRows, stackColumns } = sheetLayout;

// The one binding that is not a straight re-export. sheetLayout.paintPool is
// pure - it paints whatever data it is handed and knows nothing about C -
// so the app's copy of the character is supplied here, once, rather than by
// each of the seven mutation paths that call it.
const paintPool = (key) => sheetLayout.paintPool(key, C.data, C.conflicts);

// api() and errorDetails() come from js/api.js, loaded first as a classic script.
const jsonReq = (method, body) => ({ method, headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });

async function load() {
  try {
    const res = await api('characters/' + id);
    C.data = res.character; C.items = res.items; C.canWrite = res.can_write; C.isGm = res.is_gm;
    C.vehicles = res.vehicles || [];
    // Skill picks a level-up granted and nobody has spent yet.
    C.pendingPicks = res.pending_picks || [];
    C.skillLevelNotes = res.skill_level_notes || [];
    C.weaponBonuses = res.weapon_bonuses || [];
    C.pendingPicksTotal = res.pending_picks_total || 0;
    C.grants = res.grants || [];
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
    // Already in the response — the sheet kept only the skills until a level-up
    // had to offer the spells and powers a level grants.
    C.spellCatalog = catalogs.spells || [];
    C.pendingPowers = res.pending_powers || [];
    C.pendingPowersTotal = res.pending_powers_total || 0;
    // What each held power does, for the Powers tab. Only this character's, and
    // only the ones the catalog has text for — see the power rows below, and
    // docs/plans/20-power-descriptions.md for why it does not come from
    // /catalogs with everything else.
    C.powerDescriptions = res.power_descriptions || {};
    C.psiCatalog = catalogs.psionics || [];
    // An inventory row stores enchantment SLUGS; without the definitions a
    // slug renders as a slug.
    C.enchantCatalog = catalogs.enchantments || [];
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

// side_effects / restrictions come off the class as free text or a list.
// The powers this character actually chose, as opposed to the list its class
// offers. A repeated pick shows what the second one bought — the books give a
// second take a different meaning rather than a doubled one.
function abilitiesTaken(cls) {
  return `<div id="powers-block">${powersHtml(cls)}</div>`;
}

// What the class simply HAS, as opposed to what was chosen — the Ley Line
// Walker's sixteen ley line powers, a Demigod's regeneration. Composed classes
// concatenate both halves', so a paired character lists race and occupation
// powers alike. Entries are { name, description }; a bare string is tolerated
// because the parser normalizes the list, not its members.
function naturalAbilities(cls) {
  const list = cls?.natural_abilities || [];
  if (!list.length) return '';
  const rows = list.map((a) => {
    const name = typeof a === 'string' ? a : a?.name;
    const desc = a && typeof a === 'object' && a.description ? a.description : '';
    return `<li><b>${escHtml(name || '')}</b>
      ${desc ? `<div class="muted small">${escHtml(desc)}</div>` : ''}</li>`;
  }).join('');
  return `<h2 class="sub-h">Natural abilities</h2><ul style="margin-left:18px">${rows}</ul>`;
}

// Rebuilt in place after a G.M. edit — the same targeted-refresh discipline
// the inventory uses, because a full load() here would discard anything typed
// into the section inputs and not yet saved.
function powersHtml(cls) {
  const taken = cls?.abilities_taken || [];
  const w = C.canWrite;
  if (!taken.length && !w) return '';
  // Collapsed by name, so a power taken twice is one line saying so.
  const seen = new Map();
  for (const a of taken) if (!seen.has(a.name) || a.times > seen.get(a.name).times) seen.set(a.name, a);
  const rows = [...seen.values()].map((a) => `<li>
    <b>${escHtml(a.name)}</b>${a.times > 1 ? ` <span class="tag">taken ${a.times}&times;</span>` : ''}
    ${a.gm ? ' <span class="tag gm">G.M.</span>' : ''}
    ${a.granted === false ? ' <span class="err small">no definition found</span>' : ''}
    ${w && a.gm ? `<button class="btn btn-sm btn-ghost noprint" onclick="removeGmPower('${escJs(a.name)}')">Remove</button>` : ''}
    ${a.description ? `<div class="muted small">${escHtml(a.description)}</div>` : ''}
    ${a.on_repeat ? `<div class="small"><b>Twice:</b> ${escHtml(a.on_repeat)}</div>` : ''}
  </li>`).join('');
  // The add control offers the class's own list first — the Demigod's extra is
  // "similar to that of the godly father or mother", usually one of these — and
  // free text for a power the list does not carry. Recorded, not re-rolled:
  // pools and dice bonuses were rolled at creation, so a granted power shows its
  // text and any flat bonuses, and the G.M. adjusts numbers by hand.
  const options = [...new Set((cls?.special_abilities || [])
    .filter((e) => e && e.choose && Array.isArray(e.from)).flatMap((e) => e.from))];
  const add = w ? `<div class="rowline noprint">
      <select id="gm-power-pick" class="mini-in wide">
        <option value="">&mdash; G.M.: assign a power &mdash;</option>
        ${options.map((n) => `<option value="${escHtml(n)}">${escHtml(n)}</option>`).join('')}
        <option value="*">(type one in)</option>
      </select>
      <input id="gm-power-name" class="mini-in wide" style="display:none" placeholder="Power name">
      <button class="btn btn-sm noprint" onclick="addGmPower()">Add</button>
    </div>` : '';
  const heading = taken.length || w ? '<h2 class="sub-h">Chosen powers</h2>' : '';
  return `${heading}<ul style="margin-left:18px">${rows}</ul>${add}`;
}

// The gm-flagged subset, as the PATCH endpoint wants it.
function gmPowerNames() {
  return (C.data.abilities || [])
    .filter((e) => e && typeof e === 'object' && e.gm === true)
    .map((e) => e.name);
}

async function refreshPowers() {
  const res = await api('characters/' + id);
  C.data.abilities = res.character.abilities;
  C.cls = res.class;
  const block = $('powers-block');
  if (block) block.innerHTML = powersHtml(C.cls);
}

document.addEventListener('change', (ev) => {
  if (ev.target?.id === 'gm-power-pick') {
    const custom = $('gm-power-name');
    if (custom) custom.style.display = ev.target.value === '*' ? '' : 'none';
  }
});

async function addGmPower() {
  const pick = $('gm-power-pick');
  const name = pick?.value === '*' ? $('gm-power-name')?.value.trim() : pick?.value;
  if (!name) return;
  try {
    await api('characters/' + id, jsonReq('PATCH', { gm_abilities: [...gmPowerNames(), name] }));
    await refreshPowers();
  } catch (err) { alert(err.message); }
}

async function removeGmPower(name) {
  if (!confirm(`Remove the G.M.-assigned power "${name}"?`)) return;
  try {
    await api('characters/' + id, jsonReq('PATCH', { gm_abilities: gmPowerNames().filter((n) => n !== name) }));
    await refreshPowers();
  } catch (err) { alert(err.message); }
}

// ─── Granted skills ──────────────────────────────────────────────────────
// Things a table handed out that no class schedule granted. The G.M. says so
// out loud mid-session and the player types it in here, so nothing about this
// is G.M.-only — what carries the weight instead is that every row shows the
// reason it was given and who entered it.
//
// Its own full-width box rather than a fourth column beside Class, Related and
// Secondary, because each row carries something those do not: the reason. The
// three-column grid has no room for a sentence.
//
// Rebuilt in place after an edit, like the powers block above and for the same
// reason — a full render() would discard anything typed into the section
// inputs and not yet saved.
function grantedSkillsHtml() {
  const skills = Array.isArray(C.data?.skills) ? C.data.skills : [];
  const granted = skills.filter((s) => s.type === 'gm');
  const w = C.canWrite;
  if (!granted.length && !w) return '';

  const grantOf = (name) => (C.grants || []).find((g) => g.kind === 'skill'
    && String(g.name).toLowerCase() === String(name).toLowerCase());

  // The Remove button sits in the note row rather than beside the name,
  // because filterSkills() matches on the first cell's text — a button in
  // there would make every granted skill match a search for "remove".
  const rows = granted.map((s) => {
    const g = grantOf(s.name);
    return `<tr class="skill-row">
      <td>${escHtml(s.name)}</td>
      <td class="num">${s.per_level ? '+' + s.per_level : '—'}</td>
      <td class="num pct">${s.pct ? s.pct + '%' : '—'}</td>
    </tr>${g ? `<tr class="skill-note"><td colspan="3">
      <span class="note">↳ ${escHtml(g.reason)}
        <span class="muted">— ${escHtml(g.granted_by)}${
          g.granted_at_level ? `, at level ${g.granted_at_level}` : ''}</span></span>
      ${w ? `<button class="btn btn-sm btn-ghost noprint" onclick="removeSkillGrant(${g.id})"
        aria-label="Remove granted skill ${escHtml(s.name)}">Remove</button>` : ''}
    </td></tr>` : `<tr class="skill-note"><td colspan="3">
      <span class="note err">↳ granted, but no record of who or why</span></td></tr>`}`;
  }).join('');

  const table = granted.length ? `<table class="skill-table">
    <thead><tr class="skill-head">
      <th>Skill</th><th class="num">+%/Lvl</th><th class="num">%</th>
    </tr></thead><tbody>${rows}</tbody></table>`
    : '<p class="muted small">Nothing granted.</p>';

  // Free text with a datalist rather than a select: the catalog is the common
  // case, and a language or literacy the catalog does not name — "Language:
  // Dragonese" — is a legitimate thing for a patron to teach. The server
  // resolves those against their family's Other row.
  const add = w ? `<div class="rowline noprint" style="margin-top:8px">
      <input id="grant-name" class="mini-in wide" list="grant-skill-list"
        placeholder="Skill name" aria-label="Skill to grant">
      <input id="grant-reason" class="mini-in wide"
        placeholder="Why the table gave it (required)" aria-label="Reason">
      <button class="btn btn-sm" onclick="addSkillGrant()">Grant</button>
    </div>
    <datalist id="grant-skill-list">${(C.skillCatalog || [])
      .map((s) => `<option value="${escHtml(s.name)}">`).join('')}</datalist>` : '';

  return box('Granted', table + add);
}

async function addSkillGrant() {
  const name = $('grant-name')?.value.trim();
  const reason = $('grant-reason')?.value.trim();
  if (!name) { flash('Name the skill.', true); return; }
  // Refused here as well as on the server, so the message arrives before the
  // round trip. The reason is the whole record: anyone who can add a grant is
  // usually the one it benefits.
  if (!reason) { flash('Say why the table gave it — the reason is the record.', true); return; }
  try {
    const res = await api(`characters/${id}/grants`, jsonReq('POST', { kind: 'skill', name, reason }));
    C.data.skills = res.skills;
    C.grants = [...(C.grants || []), res.grant];
    refreshGranted();
    flash(`Granted ${res.grant.name}.`);
  } catch (err) { flash(err.message, true); }
}

async function removeSkillGrant(grantId) {
  const g = (C.grants || []).find((x) => x.id === grantId);
  if (!g) return;
  if (!confirm(`Remove the granted skill "${g.name}"?\n\n`
    + `It leaves the sheet. Why it was given — ${g.reason} — stays in the play log.`)) return;
  try {
    const res = await api(`characters/${id}/grants/${grantId}`, { method: 'DELETE' });
    C.data.skills = res.skills;
    C.grants = (C.grants || []).filter((x) => x.id !== grantId);
    refreshGranted();
  } catch (err) { flash(err.message, true); }
}

function refreshGranted() {
  const block = $('granted-block');
  if (block) block.innerHTML = grantedSkillsHtml();
  // The tab badge and the filter's "N known" are both computed inside
  // render(), which a targeted refresh deliberately does not run. Left alone
  // they read 15 with 16 rows on the page - the same species of bug as the
  // fourth skill type being invisible: a number that disagrees with what is
  // on screen, and no error anywhere.
  const badge = document.querySelector('.tabbar .tab[data-tab="skills"] .tab-n');
  if (badge) badge.textContent = (C.data?.skills || []).length;
  filterSkills(C.skillFilter);
}

const advisory = (label, value) => {
  if (!value || (Array.isArray(value) && !value.length)) return '';
  const text = Array.isArray(value) ? value.map((v) => `• ${v}`).join('\n') : String(value);
  return `<div class="advisory"><b>${label}:</b> ${escHtml(text)}</div>`;
};

// ─── Play mode ───────────────────────────────────────────────────────────
// The same character through an action-first lens, shaped for a phone at the
// table: big pool cards with quick damage/heal, and every derived number
// turned into a tappable roll. Rolls are ADVISORY - the app shows the die,
// the table decides what it means - and nothing here enforces a rule the
// sheet lens leaves to a human. Writes ride the existing PATCH; there is no
// play-specific endpoint.

// A CLASS FLIP, NOT A RE-RENDER. Both modes are in the DOM at once now, so
// switching is CSS - which means it no longer rebuilds every input on the
// sheet, and no longer eats a half-typed note. Same reason pickTab toggles
// classes rather than re-rendering.
function togglePlay() {
  C.playMode = !C.playMode;
  const url = new URL(location.href);
  if (C.playMode) url.searchParams.set('play', '1'); else url.searchParams.delete('play');
  history.replaceState(null, '', url);
  syncPlayChrome();
  sticky.sizeSticky();
}

function syncPlayChrome() {
  document.body.classList.toggle('play-mode', C.playMode);
  const t = $('play-toggle');
  if (t) { t.style.display = ''; t.textContent = C.playMode ? '📄 Sheet' : '▶ Play'; }
}

// One structured result per roll, newest kept, capped. The shape was chosen so
// a play_events row could take it unchanged, and phase 3 took it: persistRoll
// below POSTs the rollable kinds as 'roll' events and the structure never had
// to change. A 'power' roll is recorded here and NOT persisted from here -
// usePower posts its own 'power' event, carrying the from/to that undo needs.
function recordRoll(kind, name, entry) {
  const r = { kind, name, ts: Date.now(), ...entry };
  C.lastRoll = r;
  C.rollLog.push(r);
  if (kind === 'skill' || kind === 'save' || kind === 'combat' || kind === 'attack' || kind === 'damage'
    || kind === 'percentile') persistRoll(rollNote(r));
  if (C.rollLog.length > 50) C.rollLog.shift();
  const bar = $('play-roll-bar');
  if (bar) { bar.innerHTML = rollBarHtml(); bar.classList.remove('empty'); }
}

function rollBarHtml() {
  const r = C.lastRoll;
  if (!r) return '<span class="muted">Tap a skill, save or combat bonus to roll, or Percentile for a bare d100.</span>';
  if (r.note) return `<b>${escHtml(r.name)}</b> — ${escHtml(r.note)}`;
  if (r.kind === 'damage') return `<b>${escHtml(r.name)}</b> — damage ${escHtml(r.expr)} = <b>${r.total}</b>`;
  const verdict = r.ok === null ? '' : r.ok ? ' <b class="ok">✓</b>' : ' <b class="ko">✗</b>';
  if (r.die === 100) {
    // A BARE PERCENTILE HAS NOTHING TO BEAT. Every other d100 here is a skill's
    // own percentage, so this branch used to be able to assume a target; the
    // one the G.M. asks for by name has none, and reading `r.target` through
    // the same string prints `vs null%`. Null is the statement that the table
    // decides what the number meant, which is also why `verdict` is absent.
    if (r.target == null) return `<b>${escHtml(r.name)}</b> — rolled <b>${r.roll}</b> on d100`;
    return `<b>${escHtml(r.name)}</b> — rolled <b>${r.roll}</b> vs ${r.target}%${verdict}`;
  }
  const vs = r.target ? ` vs ${r.target}+` : '';
  const bonus = r.bonus ? (r.bonus > 0 ? ` + ${r.bonus}` : ` − ${-r.bonus}`) : '';
  return `<b>${escHtml(r.name)}</b> — d20 ${r.roll}${bonus} = <b>${r.total}</b>${vs}${verdict}`;
}

// d100 roll-under against a percentage.
function rollSkill(name, pct) {
  const roll = 1 + Math.floor(Math.random() * 100);
  recordRoll('skill', name, { die: 100, roll, target: pct, ok: roll <= pct });
}

// A BARE PERCENTILE — the roll a G.M. asks for by name, several times a
// session: "give me a percentile." No skill, no bonus, no target; the table
// said what it was for before asking and the table reads the number.
//
// Until this existed the sheet could roll a d100 only as a skill's own
// percentage, so the roll asked for most often at the table was the one roll
// the app had no button for and the player reached for physical dice.
//
// It goes through recordRoll rather than rolling inline, which is what puts it
// in the roll bar, the capped roll log and the session log on the same terms as
// every other roll. `target` is null on purpose and `ok` with it: a roll with
// nothing to beat has no verdict, and rollBarHtml and rollNote each read that
// null rather than printing `vs null%`.
function rollPercentile() {
  const roll = 1 + Math.floor(Math.random() * 100);
  recordRoll('percentile', 'Percentile', { die: 100, roll, target: null, ok: null });
}

// d20 + bonus, against a target where one is derived (the psionic save), and
// bonus-only where the book leaves the target to the G.M.
function rollD20(kind, name, bonus, target) {
  const roll = 1 + Math.floor(Math.random() * 20);
  const b = Number(bonus) || 0;
  recordRoll(kind, name, { die: 20, roll, bonus: b, total: roll + b,
    target: target || null, ok: target ? roll + b >= target : null });
}

// Every ⚡ button carries the pool it spends and what it costs, so its disabled
// state can be re-read from C.data without a render. Play mode moves a pool by
// targeted DOM update rather than a re-render - see adjustPool below - so a
// button rendered live stays live after the pool it spends has run out, which
// is the same false promise one action later. Called wherever a pool moves.
function syncPowerBtns() {
  for (const b of document.querySelectorAll('button[data-pool][data-cost]')) {
    const left = C.data[b.dataset.pool + '_current'];
    b.disabled = left != null && left < Number(b.dataset.cost);
  }
}

// Quick pool arithmetic: optimistic, targeted DOM update, PATCH behind it.
// No clamping - negative H.P. is a real Palladium state (coma), and a G.M.
// may allow over-maximum; arithmetic is offered, never enforced.
async function adjustPool(key, delta) {
  const cur = C.data[key + '_current'];
  if (cur == null) return;
  const next = cur + delta;
  const prev = cur;
  C.data[key + '_current'] = next;
  paintPool(key);
  syncPowerBtns();
  try {
    await postEvent('pool', `${key.toUpperCase()} ${delta > 0 ? '+' : ''}${delta}`, { character: { [key + '_current']: { from: prev, to: next } } });
  } catch (err) {
    // A REFUSAL AND A SILENCE ARE DIFFERENT THINGS. err.status means the
    // server answered and said no - a bad field, a gone character - and the
    // change was never valid, so it rolls back the way it always did. No
    // status means the request never arrived: the change is fine and the
    // wi-fi is not, so it stands on screen and waits in the queue.
    if (err.status === undefined && await queueChange('pool',
      `${key.toUpperCase()} ${delta > 0 ? '+' : ''}${delta}`,
      { [key + '_current']: { from: prev, to: next } })) {
      renderQueueState();
      return;
    }
    C.data[key + '_current'] = prev;
    paintPool(key);
    syncPowerBtns();
    alert('Failed: ' + err.message);
  }
}

// ---------- the queue ----------
// See js/play-queue.js for what this does and does not promise. The short
// version: it survives a network drop and a reload with the tab open, and it
// is not offline support.

// A change that could not be sent. ONE ENTRY PER PRESS, however many pools the
// press moved: a Damage that spills out of S.D.C. into H.P. is ONE event, and
// queueing it as two would put two rows in the log, let undo take back half a
// hit, and make the session recap count one blow as two.
//
// Returns false if the queue is not usable at all - a private window, site
// data blocked - in which case the caller rolls back exactly as it did before
// there was a queue.
// `item` is the inventory-row change an ammo write makes, carried beside the
// pools rather than instead of them, because the endpoint applies a whole
// entry in one batch.
//
// AN ITEM CHANGE IS NOT GUARDED ON REPLAY, and that is worth knowing rather
// than discovering. The guard is per POOL: the endpoint compares each numeric
// `from` and refuses if it moved. `character_items.notes` has no such check -
// online either, today - so a replayed ammo write overwrites whatever the notes
// say when it lands. Queueing does not introduce that; it lengthens the window
// from milliseconds to however long the wi-fi is out. The alternative was
// losing the shots a player fired offline, which is worse and far likelier
// than somebody hand-editing that row's notes mid-fight.
async function queueChange(kind, note, fields, item) {
  if (!window.playQueue || !(await playQueue.available())) return false;
  try {
    await playQueue.push({ characterId: Number(id), kind, note, fields, item });
    return true;
  } catch { return false; }
}

// AN ENTRY CAN OUTLIVE THE SHAPE IT WAS WRITTEN IN. IndexedDB survives a
// deploy, so a player who queued a pool change before this shipped has a
// one-field `{key, from, to}` row waiting; it replays as the 'pool' change it
// always was rather than being dropped or crashing the flush.
// THREE SHAPES now. The third is defensive rather than load-bearing: an ammo
// entry passes an empty field map explicitly, so it does not reach that branch
// today. It is there because falling through to `e.key` on an entry with no
// pools would build a field literally named `undefined_current`, which the
// endpoint refuses outright - a whole entry lost to a shape nobody meant.
function entryFields(e) {
  if (e.fields) return e.fields;
  if (e.key) return { [e.key + '_current']: { from: e.from, to: e.to } };
  return {};
}

// Replay everything queued for this character, oldest first. ORDER IS THE
// CONTRACT: two adjustments to the same pool only compose if they are sent in
// the sequence they were made, which is why this is a serial loop and not a
// Promise.all.
async function flushQueue() {
  if (!window.playQueue || !C.canWrite || !(await playQueue.available())) return;
  const pending = (await playQueue.all(Number(id))).sort((a, b) => a.seq - b.seq);
  if (!pending.length) { renderQueueState(); return; }

  for (const e of pending) {
    let res;
    try {
      res = await api(`characters/${id}/events`, jsonReq('POST', {
        kind: e.kind || 'pool',
        note: e.note,
        guard: true,
        changes: e.item ? { character: entryFields(e), item: e.item } : { character: entryFields(e) },
      }));
    } catch (err) {
      if (err.status === 409 && err.detail?.conflict) {
        // Someone else moved these pools while we were away. Stop here: the
        // entries behind this one are built on a value that is no longer
        // true, and replaying them would compound the divergence rather
        // than resolve it. The player chooses, then the flush resumes.
        //
        // ONE PRESS CAN CLASH ON TWO POOLS - a Damage that spilled into H.P.
        // while somebody else was healing. Each gets its own choice, all of
        // them carrying this entry's seq, and the entry is not resolved until
        // the last one is answered. A 409 naming none of our fields is not
        // something the player can act on, so it falls through and is treated
        // as the refusal it is.
        if (noteConflicts(e, err.detail.fields)) return;
      }
      if (err.status === undefined) { renderQueueState(); return; }  // still offline
      // The server refused it on its merits. It will never succeed, so it
      // leaves the queue rather than blocking everything behind it.
      await playQueue.remove(e.seq);
      continue;
    }

    // A REQUEST THAT LANDS ON THE ACCESS LOGIN PAGE COMES BACK AS HTML, and
    // api() answers {} for a body it cannot parse - so a replay after the
    // session expired looks exactly like success. The event id is the proof
    // that our API answered and not the login wall.
    if (!res || res.event_id == null) {
      flash('Queued changes need you to sign in again. Reload the page.', true);
      renderQueueState();
      return;
    }
    await playQueue.remove(e.seq);
  }
  renderQueueState();
  await load();
}

// Both sides of every pool this entry clashed on, each answerable on its own
// card. Returns whether anything was recorded: a 409 that names none of the
// fields we sent is not a choice the player can make, and the caller treats it
// as a refusal rather than stalling the queue on a conflict nobody can see.
function noteConflicts(entry, reported) {
  let any = false;
  for (const field of Object.keys(entryFields(entry))) {
    const f = reported?.[field];
    if (!f) continue;
    const key = field.replace('_current', '');
    C.conflicts[key] = { mine: f.mine, theirs: f.theirs, seq: entry.seq, field };
    paintPool(key);
    any = true;
  }
  if (any) renderQueueState();
  return any;
}

// How many are waiting, said once, near the pools they belong to.
async function renderQueueState() {
  const el = $('queue-state');
  if (!el || !window.playQueue) return;
  let n = 0;
  // n = 0 rather than an early return: a browser that refuses IndexedDB has no
  // queue to count and can still have lost rolls to report.
  try { n = await playQueue.count(Number(id)); } catch { n = 0; }
  const conflicts = Object.keys(C.conflicts).length;
  const lost = C.rollsNotLogged || 0;
  el.className = (n || lost) ? 'queue-state on' : 'queue-state';

  const parts = [];
  // Plural because one Damage can clash on two pools at once, and being told to
  // resolve "the" highlighted pool while two are lit is a small lie.
  if (n) parts.push(conflicts
    ? `${n} change${n === 1 ? '' : 's'} waiting — resolve the highlighted pool${conflicts === 1 ? '' : 's'}`
    : `${n} change${n === 1 ? '' : 's'} waiting for the network`);
  // NOT "waiting" - these are gone. Said plainly, because the alternative is a
  // player wondering why the session recap is thin.
  if (lost) parts.push(`${lost} roll${lost === 1 ? '' : 's'} not logged`);
  el.textContent = parts.join(' · ');
}

// The player picked a side for ONE pool. Their value is written from the
// server's current one as the base, so the write cannot fail on the same
// conflict twice.
//
// A press that clashed on two pools has two choices to make, and nothing is
// written until the last of them is in - the entry then replays as ONE event,
// the way it would have arrived had the wi-fi held. Answering half a Damage
// and sending it would be the split this queue exists to avoid.
async function resolveConflict(key, side) {
  const c = C.conflicts[key];
  if (!c) return;
  const chosen = side === 'mine' ? c.mine : c.theirs;

  // Answered: it leaves `conflicts` so the card stops offering the choice, and
  // waits in `resolved` for the rest of its press.
  delete C.conflicts[key];
  const answers = C.resolved[c.seq] || (C.resolved[c.seq] = {});
  answers[c.field] = { base: c.theirs, to: chosen };
  C.data[key + '_current'] = chosen;
  paintPool(key);
  if (Object.values(C.conflicts).some((x) => x.seq === c.seq)) {
    renderQueueState();
    return;
  }

  const entry = (await playQueue.all(Number(id))).find((x) => x.seq === c.seq);
  try {
    if (entry) {
      // Rebased on what the server holds NOW. A field the player answered is
      // based on `theirs`; a field nobody moved keeps the `from` it was queued
      // with, because its guard matched and that IS what the server holds.
      // A field that ends where it already is needs no write at all, which is
      // what makes "theirs" free.
      const changes = {};
      for (const [field, fv] of Object.entries(entryFields(entry))) {
        const a = answers[field];
        const from = a ? a.base : fv.from;
        const to = a ? a.to : fv.to;
        if (from !== to) changes[field] = { from, to };
      }
      if (Object.keys(changes).length) {
        await api(`characters/${id}/events`, jsonReq('POST', {
          kind: entry.kind || 'pool', note: `${entry.note} (resolved)`, guard: true,
          changes: { character: changes },
        }));
      }
      await playQueue.remove(c.seq);
    }
  } catch (err) {
    // The entry is still queued and the answers are dropped, so the next flush
    // asks again rather than leaving a half-answered press in limbo.
    delete C.resolved[c.seq];
    alert('Could not resolve: ' + err.message);
    return;
  }
  delete C.resolved[c.seq];
  await flushQueue();
}

// The book's damage flow, offered as one button: M.D.C. beings take it on
// M.D.C.; everyone else runs S.D.C. down first and the remainder reaches
// H.P. Armour is deliberately not in the cascade - which armour absorbed a
// hit is a table decision, and its M.D.C. is edited on its own card.
async function quickDamage() {
  const amt = C.playAmt;
  const patch = {};
  if (C.data.mdc_max != null) {
    patch.mdc_current = (C.data.mdc_current ?? 0) - amt;
  } else {
    const sdc = C.data.sdc_current ?? 0;
    const offSdc = Math.min(Math.max(sdc, 0), amt);
    if (offSdc > 0) patch.sdc_current = sdc - offSdc;
    const rest = amt - offSdc;
    if (rest > 0) patch.hp_current = (C.data.hp_current ?? 0) - rest;
  }
  const prev = {};
  for (const k of Object.keys(patch)) {
    prev[k] = C.data[k];
    C.data[k] = patch[k];
    paintPool(k.replace('_current', ''));
  }
  const fields = Object.fromEntries(Object.keys(patch).map((k) => [k, { from: prev[k], to: patch[k] }]));
  try {
    await postEvent('damage', `took ${amt}`, { character: fields });
  } catch (err) {
    // THE SAME SPLIT THE +/- BUTTONS MAKE, and for the same reason: a hit that
    // the server refused was never valid and rolls back, but a hit the wi-fi
    // ate happened at the table and stands. Damage is the press this matters
    // most for - it is the one a player cannot simply do again, because doing
    // it again means deciding a second time how much came off.
    if (err.status === undefined && await queueChange('damage', `took ${amt}`, fields)) {
      renderQueueState();
      return;
    }
    for (const k of Object.keys(prev)) {
      C.data[k] = prev[k];
      paintPool(k.replace('_current', ''));
    }
    alert('Failed: ' + err.message);
  }
}

function setPlayAmt(n) {
  C.playAmt = n;
  document.querySelectorAll('.play-amt button').forEach((b) => {
    b.classList.toggle('on', Number(b.dataset.amt) === n);
  });
}

// ── Play mode phase 3: the event log ──
// Every state-changing play action goes through ONE endpoint that applies the
// change and records it atomically; rolls persist as pure records. That buys
// undo (server reverses the latest recorded from/to), a who-did-what trail,
// and the end-of-session journal recap. Optimism is unchanged: the DOM
// updates first and reverts if the POST fails.

async function postEvent(kind, note, changes) {
  return api(`characters/${id}/events`, jsonReq('POST', { kind, note, changes }));
}

// Rolls are pure records: fire-and-forget, never blocking the table on a
// network hiccup, and skipped entirely for read-only visitors.
//
// A ROLL IS DELIBERATELY NOT QUEUED. It carries no state change, so there is
// nothing to replay and nothing to guard, and queueing every tap of an offline
// fight would fill the queue with commentary while the pools it exists for
// waited behind it.
//
// IT NO LONGER FAILS IN SILENCE, THOUGH, which is the part that was wrong.
// This was a bare console.warn - not a place a player looks - so a whole
// fight's rolls could be missing from the end-of-session recap with nothing on
// screen having said so. The count is shown beside the waiting changes now. It
// only ever grows within a session, on purpose: a roll that did not log is
// GONE, not pending, and clearing the notice when the network returned would
// hide exactly the loss it is there to report.
function persistRoll(note) {
  if (!C.canWrite) return;
  postEvent('roll', note).catch((e) => {
    C.rollsNotLogged = (C.rollsNotLogged || 0) + 1;
    console.warn('roll not logged:', e.message);
    renderQueueState();
  });
}

function rollNote(r) {
  // A targetless d100 is a bare percentile, and it has no verdict. The em-dash
  // pass/fail is deliberately absent rather than guessed: endSession counts
  // `— pass` and `— fail` out of these notes, so a percentile that invented one
  // would put a verdict nobody rolled into the session recap. It still counts
  // as a roll there, which is what "of those with a target" already allows for.
  if (r.die === 100) {
    return r.target == null
      ? `${r.name}: ${r.roll} on d100`
      : `${r.name}: ${r.roll} vs ${r.target}% — ${r.ok ? 'pass' : 'fail'}`;
  }
  if (r.kind === 'damage') return `${r.name}: damage ${r.expr} = ${r.total}`;
  const vs = r.target ? ` vs ${r.target}+ — ${r.ok ? 'pass' : 'fail'}` : '';
  return `${r.name}: d20 ${r.roll}${r.bonus ? (r.bonus > 0 ? '+' + r.bonus : r.bonus) : ''} = ${r.total}${vs}`;
}

async function undoLast() {
  try {
    const res = await api(`characters/${id}/events/undo`, jsonReq('POST', {}));
    for (const [field, v] of Object.entries(res.restored.character || {})) {
      C.data[field] = v;
      paintPool(field.replace('_current', ''));
    }
    if (res.restored.item) {
      const it = C.items.find((x) => x.id === res.restored.item.id);
      if (it) {
        it.notes = res.restored.item.notes;
        const cap = payloadCapacity(it.item_payload);
        const el = $('play-ammo-' + it.id);
        if (el && cap != null) el.textContent = `${currentAmmo(it, cap)}/${cap}`;
      }
    }
    recordRoll('undo', 'Undo', { note: `took back: ${res.undone.note || res.undone.kind}` });
  } catch (err) {
    recordRoll('undo', 'Undo', { note: err.message === 'Nothing to undo' ? 'nothing to undo' : 'failed: ' + err.message });
  }
}

// The session log: what the sheet recorded, as opposed to the journal, which
// is what a person wrote. Separate boxes because they are separate kinds of
// thing - one is a machine's account and cannot be edited, the other is prose
// and can.
//
// LOADED ON FIRST OPEN, not at render. The sheet already makes four requests
// before it can draw anything, and the log is the one thing most sessions
// never look at; paying for it every time to serve the times it is wanted is
// the wrong way round. <details ontoggle> is the whole mechanism.
let logLoaded = false;
async function loadLog() {
  const d = $('log-details'), body = $('log-body');
  if (!d || !d.open || logLoaded || !body) return;
  logLoaded = true;
  body.innerHTML = '<p class="muted small">Loading…</p>';
  let events;
  try {
    events = (await api(`characters/${id}/events?limit=300`)).events;
  } catch (err) {
    // Left retryable: a failed load must not leave the box permanently empty.
    logLoaded = false;
    body.innerHTML = `<p class="err small">Could not load: ${escHtml(err.message)}</p>`;
    return;
  }
  if (!events.length) {
    body.innerHTML = '<p class="muted small">Nothing recorded yet.</p>';
    return;
  }
  // Newest first, like the journal beside it.
  body.innerHTML = [...events].reverse().map((e) => {
    const when = String(e.created_at || '').replace('T', ' ').replace('Z', '');
    const note = e.payload?.note || e.kind;
    return `<div class="log-row${e.undone_at ? ' undone' : ''}">
      <span class="tag">${escHtml(e.kind)}</span>
      <span class="log-note">${escHtml(note)}</span>
      <span class="muted small log-when">${escHtml(when)}</span>
    </div>`;
  }).join('');
}

// The recap walks events since the last 'recap' marker, counts what happened,
// posts a journal entry, and drops the next marker. The entry is plain text a
// human can edit in the journal afterwards - the log summarises, it does not
// narrate.
async function endSession() {
  let events;
  try {
    events = (await api(`characters/${id}/events?limit=300`)).events;
  } catch (err) { alert('Could not load events: ' + err.message); return; }
  const lastRecap = [...events].reverse().find((e) => e.kind === 'recap');
  const session = events.filter((e) => (!lastRecap || e.id > lastRecap.id) && !e.undone_at && e.kind !== 'recap');
  if (!session.length) { alert('No play events since the last recap.'); return; }

  let damage = 0;
  const powers = {};
  let shots = 0, reloads = 0, rolls = 0, passes = 0, fails = 0, pools = 0;
  // Grants are listed rather than counted. "3 grants" says nothing a table
  // would want in a recap; the note already reads as a sentence.
  const grants = [];
  for (const e of session) {
    const note = e.payload?.note || '';
    if (e.kind === 'damage') { const m = note.match(/took (\d+)/); if (m) damage += +m[1]; }
    else if (e.kind === 'power') { const name = note.split(' −')[0] || note; powers[name] = (powers[name] || 0) + 1; }
    else if (e.kind === 'ammo') { if (/shot fired/.test(note)) shots++; else if (/reload/.test(note)) reloads++; }
    else if (e.kind === 'pool') pools++;
    else if (e.kind === 'grant') grants.push(note);
    else if (e.kind === 'roll') { rolls++; if (/— pass/.test(note)) passes++; else if (/— fail/.test(note)) fails++; }
  }
  const lines = [`Play session: ${session.length} actions.`];
  if (damage) lines.push(`Damage taken: ${damage}.`);
  const powerNames = Object.entries(powers).map(([n, c]) => c > 1 ? `${n} ×${c}` : n);
  if (powerNames.length) lines.push(`Powers used: ${powerNames.join(', ')}.`);
  if (shots || reloads) lines.push(`Shots fired: ${shots}${reloads ? ` (${reloads} reload${reloads > 1 ? 's' : ''})` : ''}.`);
  if (pools) lines.push(`Pool adjustments: ${pools}.`);
  for (const g of grants) lines.push(g.charAt(0).toUpperCase() + g.slice(1) + '.');
  if (rolls) lines.push(`Rolls: ${rolls}${passes + fails ? ` (${passes} passed, ${fails} failed of those with a target)` : ''}.`);

  if (!confirm(`Post this recap to the journal?\n\n${lines.join('\n')}`)) return;
  try {
    await api('journal', jsonReq('POST', {
      character_id: Number(id), title: 'Session recap',
      session_date: new Date().toISOString().slice(0, 10), body: lines.join('\n'),
    }));
    await postEvent('recap', 'session recap posted');
    recordRoll('recap', 'Session recap', { note: 'posted to the journal' });
  } catch (err) { alert('Recap failed: ' + err.message); }
}


// ── Play mode phase 2: weapon cards ──
// An equipped catalog weapon becomes an attack card: strike roll, damage
// roll off the leading dice of the gear row's damage string, and an ammo
// counter when the payload states a capacity. Ammo lives in the inventory
// row's NOTES as "ammo 7/10" - visible on the sheet lens, editable by hand,
// no schema change. Phase 3 landed and deliberately did NOT formalise it:
// play_events has an 'ammo' kind recording the notes change from/to, which
// buys undo without giving the count a column of its own.

// The first dice expression in a damage string. Books write "1D6 (small),
// 2D6 (large)" and "2D6 M.D. single shot" - the leading dice roll, the full
// string displayed, the table adjudicates the rest.
function leadingDice(damage) {
  const m = String(damage || '').match(/\d+\s*d\s*\d+(?:\s*x\s*\d+)?(?:\s*[+-]\s*\d+)?/i);
  return m ? m[0].trim() : null;
}

// Capacity is the leading integer of the payload ("10 shot magazine" -> 10).
function payloadCapacity(payload) {
  const m = String(payload || '').match(/(\d+)/);
  return m ? parseInt(m[1], 10) : null;
}

// Current ammo: the "ammo N/M" marker in notes, else full.
function currentAmmo(it, cap) {
  const m = String(it.notes || '').match(/ammo\s+(\d+)\s*\/\s*\d+/i);
  return m ? Math.min(parseInt(m[1], 10), 999) : cap;
}

// `item_slug`, NOT `item_id`. This read `it.item_id` from the day play mode
// shipped and that field has not existed since migration 046 dropped
// `character_items.item_id` (RETRO-AUDIT R21) - the GET selects
// `character_items.*` plus a set of `item_*` aliases, none of them `item_id`,
// so this returned undefined for every row and NO held item has ever become a
// weapon card. Nothing failed: the cards simply never appeared, which is the
// shape of bug a rename leaves behind.
//
// `item_slug` is the alias of `gear.slug` and is non-null exactly when the join
// resolved, which is the question this was always asking.
function isWeapon(it) {
  return it.item_slug && (it.item_damage != null || it.item_category === 'weapon');
}
// A class's trackable resources with every max_formula that CAN be resolved
// turned into a number, and every one that cannot left exactly as written.
//
// This happens here rather than in sheet-layout.js on purpose. That file reads
// no character state - it takes values and returns markup - and resolving a
// formula needs the character's attributes. Handing it rows that are already
// resolved keeps that property intact; the alternative was passing the
// character into the markup helper, which is the thing the file exists to
// avoid.
//
// Only formulas with no dice in them resolve; see fixedFormulaValue in dice.js
// for why rolling one at render time would move the character's capacity. The
// guard matches rollWeaponDamage's: dice.js is a module and this is a classic
// script, so diceRoll can genuinely be absent, and absent means show the
// formula - which is what the sheet did with all of them before.
function resolvedResources(list, attrs) {
  if (!Array.isArray(list)) return list;
  const fixed = globalThis.diceRoll && diceRoll.fixedFormulaValue;
  if (!fixed) return list;
  return list.map((r) => {
    if (!r || r.max != null || !r.max_formula) return r;
    const v = fixed(r.max_formula, attrs);
    return v == null ? r : { ...r, max: v };
  });
}

function rollWeaponDamage(name, expr) {
  const total = globalThis.diceRoll ? diceRoll.evalDice(expr) : null;
  if (total == null) return;
  recordRoll('damage', name, { expr, total, roll: total, die: null, target: null, ok: null });
}

async function writeAmmo(invId, next, cap, ammoNote) {
  const it = C.items.find((x) => x.id === invId);
  if (!it) return;
  const marker = `ammo ${next}/${cap}`;
  const base = String(it.notes || '').replace(/ammo\s+\d+\s*\/\s*\d+/i, '').replace(/\s*;\s*$/, '').trim();
  const notes = base ? `${base}; ${marker}` : marker;
  const prev = it.notes;
  it.notes = notes;
  const el = $('play-ammo-' + invId);
  if (el) el.textContent = `${next}/${cap}`;
  try {
    await postEvent('ammo', ammoNote, { item: { id: invId, notes: { from: prev || '', to: notes } } });
  } catch (err) {
    // Shots fired offline are the case this exists for: without it the counter
    // snaps back to full while the player knows they emptied the magazine, and
    // firing them again means inventing a number. Queued as an ITEM change
    // carrying no pools - see queueChange on why it replays unguarded.
    if (err.status === undefined && await queueChange('ammo', ammoNote, {},
      { id: invId, notes: { from: prev || '', to: notes } })) {
      renderQueueState();
      return;
    }
    it.notes = prev;
    if (el) el.textContent = `${currentAmmo(it, cap)}/${cap}`;
    alert('Failed: ' + err.message);
  }
}

function fireShot(invId, cap, name) {
  const it = C.items.find((x) => x.id === invId);
  if (!it) return;
  const cur = currentAmmo(it, cap);
  if (cur <= 0) { recordRoll('ammo', name, { note: 'empty - reload' }); return; }
  writeAmmo(invId, cur - 1, cap, `${name}: shot fired - ${cur - 1}/${cap} left`);
  recordRoll('ammo', name, { note: `shot fired - ${cur - 1}/${cap} left` });
}

function reloadAmmo(invId, cap, name) {
  writeAmmo(invId, cap, cap, `${name}: reloaded - ${cap}/${cap}`);
  recordRoll('ammo', name, { note: `reloaded - ${cap}/${cap}` });
}

function weaponCardsHtml(w, strikeBonus) {
  const weapons = C.items.filter(isWeapon);
  if (!weapons.length) return '';
  const equipped = weapons.filter((it) => it.equipped);
  const carried = weapons.filter((it) => !it.equipped);
  const cards = equipped.map((it) => {
    const name = it.item_name || it.custom_name || '?';
    const safe = escJs(name);
    const dice = leadingDice(it.item_damage);
    const cap = payloadCapacity(it.item_payload);
    const ammo = cap != null ? currentAmmo(it, cap) : null;
    return `<div class="play-weapon">
      <div class="pw-head"><b>${escHtml(name)}</b>${it.qty > 1 ? ` <span class="muted small">×${it.qty}</span>` : ''}
        ${it.item_damage ? `<span class="muted small">${escHtml(it.item_damage)}</span>` : ''}</div>
      <div class="pw-btns">
        <button onclick="rollD20('attack', '${safe} — strike', ${Number(strikeBonus) || 0}, null)">🎯 Strike</button>
        ${dice ? `<button onclick="rollWeaponDamage('${safe}', '${escHtml(dice)}')">💥 ${escHtml(dice)}</button>` : ''}
        ${cap != null && w ? `<button onclick="fireShot(${it.id}, ${cap}, '${safe}')">🔫 <span id="play-ammo-${it.id}">${ammo}/${cap}</span></button>
        <button class="ghost" onclick="reloadAmmo(${it.id}, ${cap}, '${safe}')">↻</button>` : ''}
      </div>
    </div>`;
  }).join('');
  const carriedLine = carried.length
    ? `<p class="muted small">Carried, not equipped: ${carried.map((it) => escHtml(it.item_name || it.custom_name)).join(' · ')} — equip on the sheet lens for cards.</p>`
    : '';
  return `<details class="play-sec" open><summary>Weapons</summary>${cards || '<p class="muted small">No equipped weapons.</p>'}${carriedLine}</details>`;
}


// ── Play mode phase 4: melee round counter + rest ──
// The counter is table ephemera - client state, deliberately not persisted;
// a round in progress is not character data. Attacks-per-melee comes from
// the derived combat block (base 2 + class bonuses + whatever a human typed).
//
// Rest applies rate x hours to each pool in ONE undoable event. The RATES
// ARE THE TABLE'S OWN, deliberately: the books' recovery pages are not yet
// in the rules audit, and this app does not ship an uncited number for a
// table to silently trust. Typed rates are remembered per character on the
// device (localStorage - a convenience, not character data). The day the
// recovery pages are audited, cited defaults land in js/rules.js and this
// comment changes.

function meleeState() {
  if (!C.melee) C.melee = { round: 1, attack: 1 };
  return C.melee;
}

// ONE ROLL CONTROL, used by every rollable row on the sheet.
//
// Play mode used to be a second render path that drew the same skills, saves
// and combat bonuses again as .play-roll buttons. It is a MODE now: the sheet
// renders once, and these buttons sit beside the numbers, hidden until
// body.play-mode shows them. The rows themselves stay tables and field divs,
// which is what keeps print unchanged - a row that BECAME a button would have
// vanished from paper, because the print block hides every button outright.
//
// Not gated on `w`: rolling changes nothing, and a read-only viewer at the
// table rolls their own dice. The old play path did not gate it either.
function rollBtn(r) {
  const safe = escJs(String(r.name));
  const call = r.pct != null
    ? `rollSkill('${safe}', ${Number(r.pct) || 0})`
    : `rollD20('${r.kind}', '${safe}', ${Number(r.bonus) || 0}, ${r.target ?? null})`;
  return `<button type="button" class="roll-btn noprint"
    aria-label="Roll ${safe}" onclick="${call}">🎲</button>`;
}

// Everything play mode adds to the sheet: the amount strip, the melee counter,
// the weapon cards and the rest panel. Rendered ALWAYS and shown by CSS, so
// switching modes is a class flip rather than a re-render - which is what lets
// togglePlay stop rebuilding the page and stop eating a half-typed note, the
// same reason pickTab toggles classes instead of re-rendering.
function playControlsHtml(w, combat) {
  const amts = [1, 5, 10, 20].map((n) =>
    `<button data-amt="${n}" class="${n === C.playAmt ? 'on' : ''}" onclick="setPlayAmt(${n})">${n}</button>`).join('');
  return `<div id="play-controls" class="noprint">
    ${w ? `<div class="play-amt"><span class="muted small">Amount</span>${amts}
      <button class="dmg" onclick="quickDamage()">💥 Damage</button>
      <button onclick="undoLast()">↶</button>
      <button onclick="endSession()">✎ End session</button></div>` : ''}
    <div class="play-melee">
      <span id="play-melee-label">${meleeLabel(combat.attacks)}</span>
      <span>
        <button onclick="nextAttack(${Number(combat.attacks) || 0})">Next attack</button>
        <button onclick="newRound(${Number(combat.attacks) || 0})">New round</button>
        <button class="ghost" onclick="resetMelee(${Number(combat.attacks) || 0})">⟲</button>
      </span>
    </div>
    <div class="play-dice">
      <span class="muted small">G.M. call</span>
      <button type="button" onclick="rollPercentile()">🎲 Percentile (d100)</button>
    </div>
    ${weaponCardsHtml(w, combat.strike)}
    ${w ? restPanelHtml() : ''}
  </div>`;
}
function meleeLabel(attacksPer) {
  const m = meleeState();
  return `Round ${m.round} — attack ${m.attack} of ${attacksPer || '?'}`;
}

function nextAttack(attacksPer) {
  const m = meleeState();
  if (attacksPer && m.attack >= attacksPer) { m.attack = 1; m.round += 1; }
  else m.attack += 1;
  const el = $('play-melee-label');
  if (el) el.textContent = meleeLabel(attacksPer);
}

function newRound(attacksPer) {
  const m = meleeState();
  m.round += 1; m.attack = 1;
  const el = $('play-melee-label');
  if (el) el.textContent = meleeLabel(attacksPer);
}

function resetMelee(attacksPer) {
  C.melee = { round: 1, attack: 1 };
  const el = $('play-melee-label');
  if (el) el.textContent = meleeLabel(attacksPer);
}

// ── rest ──
const REST_KEY = () => `cc-play-rest-${id}`;

function restPrefs() {
  try { return JSON.parse(localStorage.getItem(REST_KEY())) || {}; } catch { return {}; }
}

function saveRestPrefs(p) {
  try { localStorage.setItem(REST_KEY(), JSON.stringify(p)); } catch {}
}

// Recovery = rate x hours per pool, clamped to the pool's max (recovering
// past full is not recovery; the steppers still allow over-max by hand).
function restPreview() {
  const hours = Math.max(0, Number($('rest-hours')?.value) || 0);
  const out = [];
  for (const [key, label] of POOLS) {
    if (C.data[key + '_max'] == null) continue;
    const rate = Math.max(0, Number($(`rest-rate-${key}`)?.value) || 0);
    const cur = C.data[key + '_current'] ?? 0;
    const max = C.data[key + '_max'];
    const gain = Math.min(Math.round(rate * hours), Math.max(max - cur, 0));
    out.push({ key, label, rate, cur, gain });
  }
  return { hours, pools: out };
}

function updateRestPreview() {
  const { hours, pools } = restPreview();
  const el = $('rest-preview');
  if (!el) return;
  const parts = pools.filter((p) => p.gain > 0).map((p) => `${p.label} +${p.gain}`);
  el.textContent = hours && parts.length ? parts.join(' · ') : 'nothing to recover';
  saveRestPrefs({ hours, rates: Object.fromEntries(pools.map((p) => [p.key, p.rate])) });
}

async function applyRest() {
  const { hours, pools } = restPreview();
  const changes = { character: {} };
  const applied = [];
  for (const p of pools) {
    if (p.gain <= 0) continue;
    changes.character[p.key + '_current'] = { from: p.cur, to: p.cur + p.gain };
    applied.push(`${p.label} +${p.gain}`);
  }
  if (!applied.length) { recordRoll('rest', 'Rest', { note: 'nothing to recover' }); return; }
  const prev = {};
  for (const [field, v] of Object.entries(changes.character)) {
    prev[field] = C.data[field];
    C.data[field] = v.to;
    paintPool(field.replace('_current', ''));
  }
  // A rest recovers P.P.E. and I.S.P. as well as H.P., so it can bring a ⚡
  // button back to life.
  syncPowerBtns();
  try {
    await postEvent('pool', `rested ${hours}h: ${applied.join(', ')}`, changes);
    recordRoll('rest', `Rested ${hours}h`, { note: applied.join(', ') });
  } catch (err) {
    // Rest is several pools at once, which is the shape a queue entry already
    // takes, so it queues for the same reason Damage does: a refusal was never
    // valid and rolls back, a drop happened at the table and stands.
    if (err.status === undefined && await queueChange('pool',
      `rested ${hours}h: ${applied.join(', ')}`, changes.character)) {
      recordRoll('rest', `Rested ${hours}h`, { note: applied.join(', ') });
      renderQueueState();
      return;
    }
    for (const [field, v] of Object.entries(prev)) {
      C.data[field] = v;
      paintPool(field.replace('_current', ''));
    }
    syncPowerBtns();
    alert('Failed: ' + err.message);
  }
}

function restPanelHtml() {
  const prefs = restPrefs();
  const rates = prefs.rates || {};
  const rows = POOLS.filter(([key]) => C.data[key + '_max'] != null).map(([key, label]) =>
    `<label class="rest-row"><span>${label} per hour</span>
      <input type="number" min="0" id="rest-rate-${key}" value="${rates[key] ?? ''}" placeholder="0" oninput="updateRestPreview()"></label>`).join('');
  return `<details class="play-sec"><summary>Rest &amp; recovery</summary>
    <p class="muted small">Your table's rates — the books' recovery pages are not yet in the
    rules audit, so nothing here ships a number for you. Set a per-hour rate per pool
    (for a per-day rule, divide or set hours to the days). Applied as one undoable event,
    clamped at each pool's max.</p>
    <label class="rest-row"><span>Hours rested</span>
      <input type="number" min="0" id="rest-hours" value="${prefs.hours ?? 8}" oninput="updateRestPreview()"></label>
    ${rows}
    <div class="rest-apply"><span id="rest-preview" class="muted small"></span>
      <button class="btn btn-sm" onclick="applyRest()">🛏 Rest</button></div>
  </details>`;
}


// The first id is 'vitals' and its label reads **Core**, and that mismatch is
// deliberate. The five pools moved to the sticky strip, so the tab holds
// attributes, combat, saves and XP and not one vital - but the id is what
// localStorage['sheet-tab-<id>'] holds and what a pasted #vitals link asks for,
// so renaming it would strand every saved tab and every link already sent.
// The label is the part a player reads; the id is the part they saved.
const TAB_IDS = ['vitals', 'skills', 'powers', 'gear', 'bio', 'notes'];

// The hash wins over the stored tab, so a link ending #gear opens on gear.
function readTab() {
  const h = location.hash.slice(1);
  if (TAB_IDS.includes(h)) return h;
  try {
    const saved = localStorage.getItem('sheet-tab-' + id);
    if (TAB_IDS.includes(saved)) return saved;
  } catch { /* storage can be blocked; the default is fine */ }
  return 'vitals';
}

// Switching tabs toggles classes rather than re-rendering. A re-render rebuilds
// every input on the sheet, and the one thing a tab press must never cost a
// player is a half-typed note.
function pickTab(tab) {
  if (!TAB_IDS.includes(tab)) return;
  C.tab = tab;
  try { localStorage.setItem('sheet-tab-' + id, tab); } catch { /* see readTab */ }
  history.replaceState(null, '', '#' + tab);
  for (const el of document.querySelectorAll('.tabpanel')) {
    el.classList.toggle('on', el.dataset.tab === tab);
  }
  for (const el of document.querySelectorAll('.tabbar .tab')) {
    const on = el.dataset.tab === tab;
    el.classList.toggle('on', on);
    el.setAttribute('aria-selected', String(on));
  }
  window.scrollTo({ top: 0 });
}

// Changing only the hash is a same-document navigation - no reload, so without
// this a pasted or hand-edited '#gear' would leave the sheet on whatever tab it
// was already showing. pickTab uses replaceState rather than pushState, so Back
// still leaves the sheet for the character list instead of walking tab history.
// Queued changes go out when the network returns. A tab reopened after a
// drop has a queue and no 'online' event coming, so load() flushes too.
window.addEventListener('online', () => { flushQueue(); });

window.addEventListener('hashchange', () => {
  const tab = location.hash.slice(1);
  if (TAB_IDS.includes(tab) && tab !== C.tab) pickTab(tab);
});

// ONE RENDER PATH. There used to be two - this, and renderPlay() drawing the
// same skills, saves and combat bonuses again in a 720px single column. Play
// mode is a MODE on this sheet now: the steppers, the roll controls, the
// control strip and the roll bar are all in the markup below, and
// body.play-mode is what shows them.
//
// The sheet earned that. Play mode existed because the sheet did not work on a
// phone; it has sticky vitals, tabs below 820px and 44px targets throughout,
// so the second layout was answering a question that had stopped being asked.
function render() {
  syncPlayChrome();
  const c = C.data, w = C.canWrite;
  if (!C.tab) C.tab = readTab();
  const skills = Array.isArray(c.skills) ? c.skills : [];
  const powers = Array.isArray(c.powers) ? c.powers : [];
  // Within a box the language families read as one block: every "Language: X"
  // and "Literacy: X" gathers at the position of the first one, alphabetized
  // inside the run — which puts the spoken ones before the written ones — while
  // everything else keeps its stored order, because class skills mirror the
  // book's O.C.C. list and re-sorting the whole box would lose that.
  const clusterLanguages = (list) => {
    const langs = list.filter((s) => langSkills.isFamilyName(s.name))
      .sort((a, b) => a.name.localeCompare(b.name));
    if (langs.length < 2) return list;
    let placed = false;
    return list.flatMap((s) => {
      if (!langSkills.isFamilyName(s.name)) return [s];
      if (placed) return [];
      placed = true;
      return langs;
    });
  };
  const byType = (t) => clusterLanguages(skills.filter((s) => s.type === t));

  // Skills carry +%/Lvl and % columns, as on the printed sheet.
  //
  // A REAL <table> WITH A REAL <thead>, and that is the whole point of it.
  // This was three divs on a CSS grid, which reads as a table and prints like
  // a list: `display: table-header-group` is what repeats a header across
  // printed pages and it has nothing to attach to on a <div>. Proved on a
  // headless render (UI-AUDIT F17/F29) - a Class Skills list padded to 70
  // entries ran onto a second page that began mid-list with no column
  // headings, while the equipment table two boxes down repeated its own
  // correctly, because it was already a table.
  //
  // The note is its own <tr> rather than a fourth cell. On the grid it was
  // `grid-column: 1 / -1`, a second line spanning the full width; a table row
  // cannot hold a cell that wraps underneath its siblings, so it takes a row
  // of its own with colspan. The dotted rule then belongs to whichever of the
  // two is last, which the stylesheet handles with :has().
  const skillBox = (title, list) => box(title, list.length ? `
    <table class="skill-table">
      <thead><tr class="skill-head">
        <th>Skill</th><th class="num">+%/Lvl</th><th class="num">%</th>
      </tr></thead>
      <tbody>${list.map((s) => `<tr class="skill-row">
        <td>${escHtml(s.name)}${s.iq_bonus ? ` <span class="note-inline" title="Includes a one-time +${s.iq_bonus}% from I.Q.">+${s.iq_bonus} I.Q.</span>` : ''}</td>
        <td class="num">${s.per_level ? '+' + s.per_level : '—'}</td>
        <td class="num pct">${s.pct ? s.pct + '%' : '—'}${s.pct ? rollBtn({ name: s.name, pct: s.pct }) : ''}</td>
      </tr>${s.note ? `<tr class="skill-note"><td colspan="3">
        <span class="note">↳ ${escHtml(s.note)}</span></td></tr>` : ''}`).join('')}</tbody>
    </table>` : '<p class="muted small">None.</p>');

  // stepper: true unconditionally. There is one render now, so the steppers
  // have to be IN it; styles.css shows them only under body.play-mode, which
  // is what poolCard's own comment already promised - "CSS still gates it on
  // body.play-mode, so a sheet-mode render cannot leak steppers".
  const vitals = POOLS.map(([key, label]) =>
    poolCard(key, label, c[key + '_current'], c[key + '_max'], w, true)).join('');

  // Display order: spells first, by level then name; psionics after, by
  // category (Healing/Physical/Sensitive/Super — alphabetical IS the book
  // order) then name. Unleveled spells and uncategorized psionics sink to the
  // end of their half. Each entry keeps its original index because usePower()
  // indexes C.data.powers, which stays in stored order — sorting the stored
  // array would make the use button deduct the wrong power.
  const powerView = powers.map((p, i) => ({ p, i })).sort((a, b) => {
    const A = a.p, B = b.p;
    if ((A.type === 'spell') !== (B.type === 'spell')) return A.type === 'spell' ? -1 : 1;
    if (A.type === 'spell') {
      const la = A.level ?? Infinity, lb = B.level ?? Infinity;
      if (la !== lb) return la - lb;
    } else if ((A.category || '') !== (B.category || '')) {
      if (!A.category || !B.category) return A.category ? -1 : 1;
      return A.category.localeCompare(B.category);
    }
    return (A.name || '').localeCompare(B.name || '');
  });

  let lastPowerGroup = null;
  const powerRows = powerView.map(({ p, i }) => {
    const pool = p.type === 'spell' ? 'ppe' : 'isp';
    const cost = typeof p.cost === 'number' ? p.cost : null;
    // The group heading carries what the per-row "spell · L3" label used to.
    const group = p.type === 'spell'
      ? (p.level != null ? `Spells — Level ${p.level}` : 'Spells — Unleveled')
      : (p.category ? `Psionics — ${p.category}` : 'Psionics');
    const head = group !== lastPowerGroup ? `<div class="power-group">${escHtml(group)}</div>` : '';
    lastPowerGroup = group;
    // Offered only when the pool can pay for it. shared/styles.css already dims
    // :disabled to 0.45 and sets cursor: not-allowed, so this needs no styling
    // of its own, and usePower keeps its guard for the call arriving by hand.
    // A variable-cost power is judged on its minimum - the same number usePower
    // deducts - so the button stays live and the G.M. adjusts for the rest.
    const left = c[pool + '_current'];
    const useBtn = w && cost != null && left != null
      ? `<button class="btn btn-sm btn-ghost noprint" data-pool="${pool}" data-cost="${cost}"${left < cost ? ' disabled' : ''} onclick="usePower(${i})">⚡ use</button>` : '';
    // What the power DOES, when the catalog knows. It arrives with the
    // character (`power_descriptions`), keyed by the lowercased name this
    // character holds, so a row that resolves shows its text with no second
    // request — the point being that the lookup still works when the wifi at
    // somebody's kitchen table does not.
    //
    // The name becomes the control rather than adding a separate chevron: it is
    // the biggest target in the row and the thing a player is already looking
    // at. A row with no text keeps a plain span, so nothing offers a press that
    // does nothing.
    //
    // Which rows are open is held in state rather than read off the DOM,
    // because plenty of things re-render this sheet — spending P.P.E. with the
    // use button one row down does — and a description that closed itself when
    // you cast something would read as a bug. `i` is the index into
    // `C.data.powers`, which is stable across a render.
    const desc = (C.powerDescriptions || {})[String(p.name || '').toLowerCase()];
    const open = C.openPowerDescs.has(i);
    const nameCell = desc
      ? `<button type="button" class="power-toggle" aria-expanded="${open}"
           aria-controls="pdesc-${i}" onclick="togglePowerDesc(${i})">${escHtml(p.name)}</button>`
      : escHtml(p.name);
    // A cost_note marks a variable cost: `cost` is the minimum, the use button
    // deducts it, and the note says how the real spend grows — the G.M. adjusts
    // the pool by hand for bigger spends, as at a real table.
    return head + `<div class="power-row">
      <span>${nameCell}
        ${p.cost_note ? `<span class="muted small">— ${escHtml(p.cost_note)}</span>` : ''}</span>
      <span class="cost">${cost != null ? cost + (p.cost_note && cost > 0 ? '+' : '') + (pool === 'ppe' ? ' P.P.E.' : ' I.S.P.') : '—'}</span>
      ${useBtn}
    </div>${desc ? `<div class="power-desc" id="pdesc-${i}"${open ? '' : ' hidden'}>${escHtml(desc)}</div>` : ''}`;
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
  // attribute_bonuses are what the class's dice bonuses came up at creation.
  // Without them a Juicer's +2D6 P.S. would silently contribute nothing here.
  // Grouped, so a class's DICE combat and save bonuses count too. The legacy
  // flat shape still works — classBonuses tells them apart — but a character
  // saved since rolled_bonuses existed carries both halves.
  const bonuses = derive.classBonuses(cls, c.level, {
    attributes: c.attribute_bonuses || {},
    combat: c.rolled_bonuses?.combat || {},
    saves: c.rolled_bonuses?.saves || {},
  });
  // The same block with the SKILLS left out. `cls` arrives from the API with
  // skill bonuses already folded in, so without this there is no way to tell
  // Boxing's +1 attack per melee from the class's own - and labelling a skill's
  // bonus as the class's is simply wrong.
  const classOnly = derive.classBonuses({ ...cls, bonuses: cls.class_bonuses ?? cls.bonuses }, c.level, {
    attributes: c.attribute_bonuses || {},
    combat: c.rolled_bonuses?.combat || {},
    saves: c.rolled_bonuses?.saves || {},
  });
  const effAttrs = derive.effective(attrs, bonuses);
  const combatParts = derive.parts('combat', attrs, bonuses, undefined, classOnly);
  const savesParts = derive.parts('saves', attrs, bonuses, cls.psionics?.type, classOnly);

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
    if (p.from_skills) bits.push(`${p.from_skills > 0 ? '+' : ''}${p.from_skills} from skills taken`);
    if (!bits.length) return 'Derived from attributes — type to override';
    return `${bits.join(', ')} — type to override`;
  };

  const editField = (section, key, label, value, stored, opts = {}) => {
    const isDerived = derive.isDerived(stored, key);
    const suffix = opts.suffix || '';
    const why = isDerived ? explain(opts.parts, key) : 'Set manually';
    // A class contribution is worth seeing without hovering, so it is marked.
    // Marked whichever it came from - the styling says "this number was raised",
    // and a skill raising it is no less worth seeing without hovering.
    const pk = opts.parts?.[key];
    const fromClass = isDerived && (pk?.from_class || pk?.from_skills) ? ' class-boosted' : '';
    // The roll control, when this row is one you roll. A THIRD node beside the
    // input and the print mirror, on the same principle: one node per mode,
    // switched by CSS, rather than one node that has to be two things. It is a
    // real <button> so a keyboard can reach it, and the global print rule hides
    // every button - which is why the row's own markup could not become one.
    const roll = opts.roll ? rollBtn(opts.roll) : '';
    if (!w) {
      return `<div class="field"><span class="lbl">${label}</span><span class="dots"></span>
        <span class="val${isDerived ? ' dim' : ''}${fromClass}" title="${escHtml(why)}">${escHtml(String(value ?? '—'))}${suffix}</span>${roll}</div>`;
    }
    return `<div class="field"><span class="lbl">${label}</span><span class="dots"></span>
      <span class="val">
        <input class="mini-in${isDerived ? ' derived' : ''}${fromClass}" data-sec="${section}" data-key="${key}"
          type="${opts.type || 'text'}" value="${escHtml(stored?.[key] ?? '')}"
          placeholder="${escHtml(String(value ?? ''))}" title="${escHtml(why)}">${suffix}
        <b class="print-only">${escHtml(String(value ?? '—'))}${suffix}</b>
      </span>${roll}</div>`;
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
    ['birth_order', 'Birth Order'], ['land_of_origin', 'Land of Origin'],
    ['disposition', 'Disposition'], ['racial_bias', 'Racial Bias'],
    // Gold in Palladium, credits in Rifts. Labelled from the campaign's system
    // rather than fixed, so a Rifts sheet does not say "Gold".
    ['money', window.rules.currencyLabel(c.campaign_system)],
  ];
  // Even split, so adding a field does not lopside the block.
  const bioHalf = Math.ceil(BIO_FIELDS.length / 2);
  const COMBAT_FIELDS = [
    ['attacks', '# of Attacks'], ['initiative', 'Initiative'], ['strike', 'Strike'],
    ['parry', 'Parry'], ['dodge', 'Dodge'], ['roll', 'Roll w/ Punch'],
    ['perception', 'Perception'],
    ['damage_bonus', 'Damage'], ['punch', 'Punch'], ['power_punch', 'Power Punch'],
    ['kick', 'Kick'], ['knockout', 'Knock Out'], ['critical', 'Critical'],
    ['pull_punch', 'Pull Punch'],
    // Hand to Hand grants these; they stay at 0 for a character whose training
    // never mentions them, which is the honest reading of a blank line.
    ['disarm', 'Disarm'], ['entangle', 'Entangle'],
    ['body_flip', 'Body Flip/Throw'], ['automatic_dodge', 'Auto Dodge'],
    ['run_yards_per_melee', 'Run (yds/melee)'],
  ];
  // Short forms for the conditional-bonus list, which has no room for
  // '# of Attacks'-length labels beside a condition.
  //
  // It was a weapon-proficiency list until RETRO-AUDIT R4, when seven pilot and
  // fighting skills started carrying `applies_when` too - so the keys a robot
  // or fighter pilot earns (attacks, roll, pull_punch) needed short forms of
  // their own. A missing key falls back to the raw column name, which is how
  // `pull_punch` would have reached the sheet with an underscore in it.
  const WP_LABELS = { strike: 'strike', parry: 'parry', dodge: 'dodge', disarm: 'disarm',
    entangle: 'entangle', damage_bonus: 'damage', initiative: 'initiative',
    attacks: 'attacks', roll: 'roll w/ impact', pull_punch: 'pull punch',
    perception: 'Perception' };
  const armorRows = armorList.map((a, i) => armorSlotHtml(a, i, w)).join('');

  $('app').innerHTML = `
  ${box(`${escHtml(c.name)}${w ? '' : ' <span class="tag ro">read-only</span>'}${C.isGm ? ' <span class="tag gm">GM</span>' : ''}`, `
    <div class="sheet-grid cols-2">
      <div>
        ${field('O.C.C.', escHtml(cls.name || c.class_id))}
        ${/* A Military Occupational Specialty is part of what the character IS,
              not a skill-list detail: two Technical Officers with different
              specialties share no MOS skills at all. Shown beside the O.C.C.
              for that reason, and only when the class offers one. */''}
        ${cls.mos_chosen ? field('M.O.S.', escHtml(cls.mos_chosen.name)) : ''}
        ${field('Level', c.level)}
        ${field('Experience', `${c.xp} XP`)}
      </div>
      <div>
        ${field('Campaign', escHtml(c.campaign_name), true)}
        ${field('System', escHtml(c.campaign_system), true)}
        ${field('Player', escHtml(c.player_email), true)}
      </div>
    </div>
    `)}

  ${w && C.proposal ? levelUpPanel() : ''}
  ${w && C.variantProposal ? variantProposalPanel() : ''}
  ${w && !C.proposal && C.pendingPicksTotal ? pendingPicksPanel() : ''}
  ${w && !C.proposal && C.pendingPowersTotal ? pendingPowersPanel() : ''}

  <div class="sheet-sticky" data-sticky>
    ${vitals ? `<div class="vitals vitals-strip">${vitals}</div>
      <div id="queue-state" class="queue-state noprint"></div>
      <div class="rowline noprint vitals-save">
        ${w ? `<button class="btn btn-sm btn-primary" onclick="saveStats()">Save</button>
        <span id="msg"></span>` : ''}
        <span class="muted small">current / max</span></div>` : ''}
    <nav class="tabbar noprint" role="tablist">
      ${[['vitals', 'Core', 0], ['skills', 'Skills', skills.length],
         ['powers', 'Powers', powers.length], ['gear', 'Gear', C.items.length],
         ['bio', 'Bio', 0], ['notes', 'Notes', C.journal.length]].map(([tid, label, n]) =>
        `<button class="tab${C.tab === tid ? ' on' : ''}" data-tab="${tid}" role="tab"
           aria-selected="${C.tab === tid}" onclick="pickTab('${tid}')">${label}${
           n ? ` <span class="tab-n">${n}</span>` : ''}</button>`).join('')}
    </nav>
  </div>

  ${playControlsHtml(w, combat)}

  <div class="sheet-body sheet-grid sheet-3">
  <section class="tabpanel${C.tab === 'vitals' ? ' on' : ''}" data-tab="vitals">
  <div class="sheet-grid rail" style="margin-top:12px">
    ${box('Attributes', `<div class="attr-stack">
      ${ATTRS.map((a) => {
        const add = bonuses.attributes[a];
        const addClass = classOnly.attributes[a] || 0;
        const addSkills = (add || 0) - addClass;
        const src = !addSkills ? (cls.name || 'the class')
          : (!addClass ? 'skills taken' : `${cls.name || 'the class'} + skills taken`);
        // The stored attribute is what was rolled; the class bonus rides
        // alongside it so both stay legible, and effAttrs is what the tables read.
        return field(a, attrs[a] == null ? '—'
          : add ? `${attrs[a]} <span class="attr-bonus" title="${escHtml(`${add > 0 ? '+' : ''}${add} from ${src}`)}">${add > 0 ? '+' : ''}${add}</span> = ${effAttrs[a]}`
          : attrs[a]);
      }).join('')}
    </div>`)}

    ${vitals ? '' : box('Vitals', '<span class="muted small">None recorded.</span>')}

    ${box('Experience', `
      ${field('Level', c.level)}
      ${field('Points', c.xp)}
      ${C.nextThreshold != null ? field('Next level at', `${C.nextThreshold} XP`, true) : ''}
      ${w ? `<div class="rowline noprint" style="margin-top:6px">
        <input type="number" id="xp-delta" placeholder="+XP" style="width:78px">
        <button class="btn btn-sm" onclick="logXp()">Log XP</button></div>` : ''}`)}

    ${w && !C.variantProposal ? variantPanel() : ''}
  </div>

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
      editField('saves', k, l, saves[k], c.saves, { suffix: k === 'coma_death_pct' ? '%' : '', parts: savesParts,
        // The percentage saves roll under on d100; the rest are d20 + bonus.
        // Same split SAVE_ROLLS makes, read the same way.
        roll: k.endsWith('_pct')
          ? { name: l, pct: saves[k] }
          : { kind: 'save', name: l, bonus: saves[k],
              target: k === 'psionics' ? (saves.psionics_target || null) : null } })).join('')
      // Book-stated saves the sixteen do not name (F7), after them and READ
      // ONLY. Not editField: an editable row needs a storage key to write to,
      // and these are identified by a free-text label rather than a key. There
      // is also nothing to override — no chart contributed to them, so the
      // printed number IS the value.
      + otherSaves(cls).map((e) => {
        const v = Number(e.bonus);
        const why = e.note ? `${e.note} - stated by ${cls.name || 'the class'}`
          : `Stated by ${cls.name || 'the class'}`;
        return `<div class="field"><span class="lbl">${escHtml(e.label)}</span><span class="dots"></span>
          <span class="val dim" title="${escHtml(why)}">${v > 0 ? '+' + v : v}</span>
          ${rollBtn({ kind: 'save', name: e.label, bonus: v, target: null })}</div>`;
      }).join(''),
      '<span class="muted" style="font-size:9px">DERIVED · OVERRIDABLE</span>')}

    ${box('Combat', COMBAT_FIELDS.map(([k, l]) =>
      editField('combat', k, l, combat[k], c.combat, { parts: combatParts,
        // Only the four the old play view rolled. Attacks per melee and
        // damage bonuses are numbers you READ mid-fight, not d20 rolls,
        // and a die on them would be an invitation to roll nothing.
        roll: ROLLABLE_COMBAT.has(k)
          ? { kind: 'combat', name: l, bonus: combat[k], target: null } : null })).join('')
      // What the character's training grants that is not a number. Read-only:
      // these are capabilities the book confers at a level, not values anyone
      // edits, and every one of them is already earned by the level shown.
      + (!(C.skillLevelNotes || []).length ? '' : `
        <div class="train" style="margin-top:10px">
          <p class="muted small" style="margin:0 0 4px">Combat training</p>
          ${C.skillLevelNotes.map((n) =>
            `<p class="small" style="margin:0 0 3px">
               <span class="muted">L${Number(n.level)}</span> ${escHtml(n.note)}</p>`).join('')}
        </div>`)
      // A W.P.'s bonuses apply only while that weapon is in hand (p.326), so
      // they are shown apart from the combat numbers rather than added to them.
      // Listing them beside the block they do NOT belong to is the point: a
      // player needs both, and needs to know which is which.
      //
      // The heading no longer says "Weapon proficiencies" because W.P.s are no
      // longer the only skills here: RETRO-AUDIT R4 gave Fencing, Sniper,
      // Weapon Systems and the four robot/fighter combat trainings the same
      // `applies_when` shape, and "while piloting the Glitter Boy" is not a
      // weapon proficiency. The condition is printed per row either way.
      + (!(C.weaponBonuses || []).length ? '' : `
        <div class="wp-bonuses" style="margin-top:10px">
          <p class="muted small" style="margin:0 0 4px">
            Conditional bonuses <span class="muted">&mdash; these apply only in the situation named</span></p>
          ${C.weaponBonuses.map((w) => {
            const parts = Object.entries(w.combat)
              .map(([k, v]) => `${v > 0 ? '+' : ''}${v} ${WP_LABELS[k] || k}`).join(', ');
            return `<p class="small" style="margin:0 0 3px">
              ${escHtml(String(w.skill).replace(/^W\.P\. /, ''))}
              <span class="muted">${escHtml(w.applies_when)}</span> ${escHtml(parts)}</p>`;
          }).join('')}
        </div>`))}

    ${(() => {
      // One box per class that declares trackable resources, and none at all
      // for a class that does not - which is every class today. The title is
      // stable so the column assignment can find it; the class name rides in
      // the title bar beside it.
      const rows = trackableRows(resolvedResources(cls.trackable_resources, attrs));
      return rows ? box('Resources', rows,
        `<span class="muted small">${escHtml(cls.name || '')}</span>`) : '';
    })()}

    ${box('Armor', `<div id="armor-list">${armorRows}</div>` +
      (armorRows ? '' : '<p class="muted small" id="armor-empty">No armor recorded.</p>') +
      (w ? `<div class="rowline noprint" style="margin-top:8px">
        <button class="btn btn-sm" onclick="addArmor()">+ Add armor</button></div>` : ''))}
  </div>

  </section>

  <section class="tabpanel${C.tab === 'skills' ? ' on' : ''}" data-tab="skills">
  ${/* data-col is what stackColumns places on, so the filter carries one
        for the same reason every box does: without it the filter is a stray
        and lands under whichever column the pass files strays in - which is
        how it once rendered above Psionics, three columns from the list it
        filters. */''}
  <div class="pick-filter noprint" data-col="b">
    <input type="search" id="skill-filter" placeholder="Filter skills…"
      value="${escHtml(C.skillFilter)}"
      oninput="filterSkills(this.value)" aria-label="Filter skills">
    <span class="pick-count" id="skill-count"></span>
  </div>
  <div class="sheet-grid cols-3" style="margin-top:12px">
    ${skillBox('Class Skills', byType('occ'))}
    ${skillBox('Related Skills', byType('related'))}
    ${skillBox('Secondary Skills', byType('secondary'))}
    ${/* BOOK-INGEST-AUDIT.md F23(b). Its OWN box, because a program skill is
          not a class skill: it sits at one flat percentage that never advances,
          and filed under Class Skills it would read as an ordinary grant. A
          skillBox with nothing in it renders nothing, so every class without
          programs is unchanged - which is all but one of them. Added here
          because the sheet renders skills by an explicit list of types, so a
          new type not named here would be SAVED AND INVISIBLE. */''}
    ${skillBox('Skill Programs', byType('program'))}
  </div>
  ${/* Placed as a UNIT rather than by its contents: refreshGranted() rewrites
        this block's innerHTML long after the layout pass has run, and boxes
        written into an already-placed container inherit its column. */''}
  <div id="granted-block" class="sheet-grid" data-col="b" style="margin-top:12px">${grantedSkillsHtml()}</div>

  </section>

  <section class="tabpanel${C.tab === 'powers' ? ' on' : ''}" data-tab="powers">
    ${box('Psionics &amp; Magic', (powers.length
      ? powerRows
      : '<p class="muted small">None.</p>')
      // The held powers carry their own text; everything this character does
      // NOT have lives in the codex. Marked noprint: a link is useless on paper.
      + `<p class="muted small noprint" style="margin-top:10px">
           Looking for something this character does not have?
           <a href="codex.html">Browse the codex</a>.</p>`)}

  </section>

  <section class="tabpanel${C.tab === 'gear' ? ' on' : ''}" data-tab="gear">
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

    ${box('Vessels', `
      <div id="vessel-list">${vesselsHtml()}</div>
      ${w ? `<div class="noprint" style="margin-top:8px">
        <div class="rowline">
          <select id="add-vessel" onfocus="openVesselPicker()"><option value="">— catalog —</option></select>
          <input type="text" id="add-vessel-name" placeholder="or custom vessel">
          <input type="text" id="add-vessel-nick" placeholder="Nickname" style="width:110px">
          <button class="btn btn-sm" onclick="addVessel()">Add</button>
        </div>
        <p class="muted small">Power armour, robots, borgs, vehicles and ships. The catalog list
          loads when you open it.</p></div>` : ''}`,
      '<span class="muted small">M.D.C. BY LOCATION</span>')}
  </section>

  <section class="tabpanel${C.tab === 'bio' ? ' on' : ''}" data-tab="bio">
  <div class="sheet-grid cols-2" style="margin-top:12px">
    ${box('Background', `
      ${BIO_FIELDS.slice(0, bioHalf).map(([k, l]) => bioField(k, l, bio, c.bio)).join('')}`)}
    ${box('Bearing', `
      ${BIO_FIELDS.slice(bioHalf).map(([k, l]) => bioField(k, l, bio, c.bio)).join('')}
      ${editField('bio', 'invoke_trust_pct', 'Invoke Trust/Intimidate', bio.invoke_trust_pct, c.bio, { suffix: '%' })}
      ${editField('bio', 'charm_impress_pct', 'Charm/Impress', bio.charm_impress_pct, c.bio, { suffix: '%' })}`)}
  </div>
  </section>

  <section class="tabpanel${C.tab === 'notes' ? ' on' : ''}" data-tab="notes">
  <div class="sheet-grid cols-2" style="margin-top:12px">
    ${box('Notes', `
      ${w ? `<textarea id="stat-notes" class="noprint">${escHtml(c.notes || '')}</textarea>
             <p class="print-only small" style="white-space:pre-wrap">${escHtml(c.notes || '—')}</p>`
          : `<p class="small" style="white-space:pre-wrap">${escHtml(c.notes || '—')}</p>`}
      ${naturalAbilities(cls)}
      ${abilitiesTaken(cls)}
      ${advisory('Side effects', cls.side_effects)}
      ${advisory('Restrictions', cls.restrictions)}
      ${C.cls?._retired
        ? advisory('Retired class', 'This class has been retired and can no longer be chosen for new characters. This character is unaffected.')
        : ''}`)}

    ${box('Session log', `<details class="play-sec" id="log-details" ontoggle="loadLog()">
      <summary>What happened, as the sheet recorded it</summary>
      <div id="log-body"><p class="muted small">Opening this loads the log.</p></div>
    </details>`, '<span class="muted small">machine-written</span>')}

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
  </div>
  </section>
  </div>

  <div id="play-roll-bar" class="noprint ${C.lastRoll ? '' : 'empty'}">${rollBarHtml()}</div>`;

  // Before anything measures the page: the three column stacks are built by
  // moving nodes, and sizeSticky() reads rendered heights.
  stackColumns($('app').querySelector('.sheet-body'));

  wirePickers();
  sticky.sizeSticky();
  // A tab reopened after a drop has a queue and no 'online' event coming.
  flushQueue();
  // The count is filterSkills' job, so there is one implementation of it rather
  // than a number rendered here and a different one written on the first
  // keystroke. Re-applying C.skillFilter is also what carries a typed query
  // across a re-render, the same reason invFilter and pickFilter are state.
  filterSkills(C.skillFilter);
}

// Filter the sheet's three skill tables in place. Class, Related and Secondary
// are separate tables, so this walks all three and keeps one count across them.
//
// Rows are hidden with a class rather than re-rendered, for the reason pickTab
// gives: a re-render rebuilds every input on the sheet, and this is used
// mid-session with a half-typed journal entry sitting two tabs over.
//
// A skill carrying a note emits TWO rows - the note is its own <tr colspan="3">
// since PR #460 - so the note follows its skill into and out of hiding, or a
// filtered-out skill leaves its footnote behind pointing at nothing.
function filterSkills(q) {
  C.skillFilter = String(q ?? '');
  const needle = C.skillFilter.trim().toLowerCase();
  let shown = 0, total = 0;
  for (const row of document.querySelectorAll('.skill-table .skill-row')) {
    total++;
    const hit = !needle || (row.cells[0]?.textContent || '').toLowerCase().includes(needle);
    if (hit) shown++;
    row.classList.toggle('filtered-out', !hit);
    const note = row.nextElementSibling;
    if (note?.classList.contains('skill-note')) note.classList.toggle('filtered-out', !hit);
  }
  const el = $('skill-count');
  if (el) el.textContent = needle ? `${shown} of ${total}` : `${total} known`;
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
    <h2 class="sub-h" style="margin-top:0">⬆ Level up! ${p.from_level} → ${p.to_level}
      <span class="muted small">— review, tweak if your GM says so, then confirm</span></h3>
    <table>${poolRows}${skillRows}</table>
    ${grants ? `<h3>New abilities</h3><ul style="margin-left:18px">${grants}</ul>` : ''}
    ${p.skill_picks_total ? pickerBlock(p.skill_picks, p.skill_picks_total, 'lu') : ''}
    ${powerPickerBlock(p)}
    <div class="rowline" style="margin-top:10px">
      <button class="btn btn-primary" onclick="confirmLevelUp()">✅ Confirm level-up</button>
      <button class="btn btn-sm btn-ghost" onclick="C.proposal=null; render()">Not now</button>
      <span class="muted small">Nothing is applied until you confirm.</span>
    </div>
  </div>`;
}

// The spells and psionic powers the crossed levels earn.
//
// One select per slot, grouped by the level that granted it — because for
// spells the LEVELS a slot may draw from belong to that grant. A Ley Line
// Walker crossing into level 5 gets two spells capped at spell level 5, and if
// it crossed two levels at once the level-4 pair is capped at 4.
//
// A class whose definition records no per-level rule says so rather than
// showing an empty picker, exactly as the wizard's Advancement step does:
// "not recorded" and "none" are different answers.
function powerPickerBlock(p) {
  const blocks = [powerKindBlock(p.spell_picks, 'spell'), powerKindBlock(p.psionic_picks, 'psionic')]
    .filter(Boolean).join('');
  return blocks;
}

function powerKindBlock(grant, kind) {
  if (!grant || !grant.applicable) return '';
  const isSpell = kind === 'spell';
  const label = isSpell ? 'Spells' : 'Psionic powers';
  if (grant.unknown) {
    return `<h2 class="sub-h">${label}</h2><p class="warn small">This class's definition does not record how
      many ${isSpell ? 'spells' : 'powers'} it learns per level, so none are offered. Nothing is
      guessed — add them by hand, or re-import the class with
      <code>${isSpell ? 'spells_per_level' : 'powers_per_level'}</code>.</p>`;
  }
  if (!grant.total) return '';

  const held = new Set((C.data.powers || []).map((x) => String(x.name).toLowerCase()));
  // `slot`, `from` and `note` ride along on the grant itself, so only the level
  // cap still has to be mirrored from js/leveling.js here.
  const rows = grant.grants.map((g) => {
    const slot = g.slot ?? 0;
    const levels = isSpell ? spellLevelCap(g.level, slot) : null;
    const cats = isSpell ? null : psiCategoryCap(g.level, slot);
    // A named list is the tightest restriction and replaces the level cap.
    const named = isSpell && Array.isArray(g.from) && g.from.length
      ? new Set(g.from.map((n) => String(n).toLowerCase())) : null;
    const pool = (isSpell ? C.spellCatalog : C.psiCatalog)
      .filter((x) => !held.has(String(x.name).toLowerCase()))
      .filter((x) => !x.system || x.system === C.data.campaign_system)
      .filter((x) => !isSpell || (named ? named.has(String(x.name).toLowerCase())
                                        : (!levels || levels.includes(x.level))))
      .filter((x) => isSpell || !cats || cats.includes(x.category));
    const cap = named ? `a list of ${g.from.length}`
      : isSpell
        ? (levels ? `spell levels ${levels.join(', ')}` : 'any spell level')
        : (cats ? cats.join(', ') : 'any category');
    const note = g.note
      ? `<p class="small warn" style="margin:2px 0">${escHtml(g.note)} — the catalog cannot check
         this one, so it is yours to honour.</p>` : '';
    return note + Array.from({ length: g.count }, (_, i) => `
      <div class="rowline">
        <span class="muted small">Level ${g.level}</span>
        <select id="lu-power-${kind}-${g.level}-${slot}-${i}"
          data-level="${g.level}" data-slot="${slot}" data-kind="${kind}">
          <option value="">— leave for later —</option>
          ${pool.map((x) => `<option value="${escHtml(x.name)}">${escHtml(x.name)}${
            isSpell && x.level != null ? ` (level ${x.level})` : ''}</option>`).join('')}
        </select>
        <span class="muted small">from ${escHtml(cap)}</span>
      </div>`).join('');
  }).join('');

  return `<h2 class="sub-h">${label} <span class="muted small">— ${grant.total} earned</span></h2>
    <p class="muted small">Anything left blank is banked and waits on the sheet.</p>${rows}`;
}

// The psionic categories a grant earned AT `level` may draw from. Mirrors
// psionicCategoriesForGrant in js/leveling.js - the sheet cannot import it,
// being a classic script rather than a module.
//
// A grant's categories REPLACE the class's: the Mystic's level-4 power comes
// from Super, which its starting Sensitive/Healing powers could not.
function psiCategoryCap(level, slot = 0) {
  const psi = C.cls?.psionics;
  if (!psi) return null;
  const entry = scheduleEntryAt(psi.powers_schedule, level, slot);
  if (entry && Array.isArray(entry.categories) && entry.categories.length) return entry.categories;
  return Array.isArray(psi.categories_allowed) && psi.categories_allowed.length
    ? psi.categories_allowed : null;
}

// The nth entry at a level. Several grants can share a level with different
// restrictions - a Shifter's three spells at level 2 come from three places -
// so the slot is what tells them apart. Mirrors entryAt in js/leveling.js.
function scheduleEntryAt(schedule, level, slot) {
  if (!Array.isArray(schedule)) return null;
  return schedule.filter((e) => e?.level === level)[slot] ?? null;
}

// The spell levels a grant earned AT `level` may draw from. Mirrors
// spellLevelsForGrant in js/leveling.js, which the sheet cannot import: it is a
// classic script, not a module.
function spellLevelCap(level, slot = 0) {
  const magic = C.cls?.magic;
  if (!magic) return null;
  const entry = scheduleEntryAt(magic.spells_schedule, level, slot);
  if (entry && Array.isArray(entry.spell_levels) && entry.spell_levels.length) {
    return entry.spell_levels;
  }
  // A slot bounded by a named list is not also bounded by a spell level.
  if (entry && Array.isArray(entry.from) && entry.from.length) return null;
  const rule = magic.spells_per_level_levels;
  if (rule === 'up_to_character_level') {
    return Array.from({ length: Math.max(0, level) }, (_, i) => i + 1);
  }
  if (Array.isArray(rule) && rule.length) return rule;
  return Array.isArray(magic.spell_levels_allowed) && magic.spell_levels_allowed.length
    ? magic.spell_levels_allowed : null;
}

// Every power slot the level-up panel is showing, as the API's shape.
function collectPowerPicks() {
  return [...document.querySelectorAll('[id^="lu-power-"]')]
    .filter((el) => el.value)
    .map((el) => ({ kind: el.dataset.kind, name: el.value,
                    granted_at_level: +el.dataset.level, slot: +(el.dataset.slot || 0) }));
}

// Spell and psionic grants banked at a level-up. Shown until spent, for the
// same reason the skill picks are: banking without a way to come back to it is
// the same loss as not banking, just later.
//
// Each banked grant keeps the cap it was granted with, so this offers exactly
// what that level allowed - not what the character's CURRENT level would.
function pendingPowersPanel() {
  const n = C.pendingPowersTotal;
  if (!C.claimingPowers) {
    return `
    <div class="levelup noprint">
      <h2 class="sub-h" style="margin-top:0">✨ ${n} unspent ${n > 1 ? 'powers' : 'power'}
        <span class="muted small">— earned at ${
          C.pendingPowers.map((g) => 'level ' + g.granted_at_level).join(', ')}</span></h3>
      <button class="btn" onclick="C.claimingPowers = true; render()">Choose now</button>
    </div>`;
  }
  const held = new Set((C.data.powers || []).map((x) => String(x.name).toLowerCase()));
  const rows = C.pendingPowers.map((g) => {
    const isSpell = g.kind === 'spell';
    const named = isSpell && Array.isArray(g.from) && g.from.length
      ? new Set(g.from.map((n) => String(n).toLowerCase())) : null;
    const pool = (isSpell ? C.spellCatalog : C.psiCatalog)
      .filter((x) => !held.has(String(x.name).toLowerCase()))
      .filter((x) => !x.system || x.system === C.data.campaign_system)
      .filter((x) => !isSpell || (named ? named.has(String(x.name).toLowerCase())
                                        : (!g.spell_levels || g.spell_levels.includes(x.level))))
      .filter((x) => isSpell || !g.categories || g.categories.includes(x.category));
    // The banked row's own restriction, not the class's as it stands today.
    const cap = named ? `a list of ${g.from.length}`
      : isSpell
        ? (g.spell_levels ? `spell levels ${g.spell_levels.join(', ')}` : 'any')
        : (g.categories ? g.categories.join(', ') : 'any');
    const note = g.note
      ? `<p class="small warn" style="margin:2px 0">${escHtml(g.note)} — not checked here.</p>` : '';
    return note + Array.from({ length: g.count }, (_, i) => `
      <div class="rowline">
        <span class="muted small">Level ${g.granted_at_level}</span>
        <select id="claim-power-${g.kind}-${g.granted_at_level}-${g.slot ?? 0}-${i}"
          data-level="${g.granted_at_level}" data-slot="${g.slot ?? 0}" data-kind="${g.kind}">
          <option value="">— not yet —</option>
          ${pool.map((x) => `<option value="${escHtml(x.name)}">${escHtml(x.name)}${
            isSpell && x.level != null ? ` (level ${x.level})` : ''}</option>`).join('')}
        </select>
        <span class="muted small">from ${escHtml(cap)}</span>
      </div>`).join('');
  }).join('');
  return `
  <div class="levelup noprint">
    <h2 class="sub-h" style="margin-top:0">✨ Choose ${n} ${n > 1 ? 'powers' : 'power'}</h2>
    ${rows}
    <div class="rowline" style="margin-top:10px">
      <button class="btn btn-primary" onclick="claimPowers()">Learn these</button>
      <button class="btn btn-sm btn-ghost" onclick="C.claimingPowers = false; render()">Later</button>
    </div>
  </div>`;
}

async function claimPowers() {
  const picks = [...document.querySelectorAll('[id^="claim-power-"]')]
    .filter((el) => el.value)
    .map((el) => ({ kind: el.dataset.kind, name: el.value,
                    granted_at_level: +el.dataset.level, slot: +(el.dataset.slot || 0) }));
  if (!picks.length) { flash('Choose at least one, or leave it for later.', true); return; }
  try {
    await api(`characters/${id}/power-picks`, jsonReq('POST', { picks }));
    C.claimingPowers = false;
    await load();
  } catch (err) {
    const details = errorDetails(err);
    alert(['Could not learn those: ' + err.message, ...details.map((d) => '- ' + d)].join('\n'));
  }
}

// Picks earned at a level-up and skipped. Shown until they are spent, so a
// banked grant does not quietly disappear from view.
function pendingPicksPanel() {
  const n = C.pendingPicksTotal;
  if (!C.claiming) {
    return `
    <div class="levelup noprint">
      <h2 class="sub-h" style="margin-top:0">🎓 ${n} unspent skill pick${n > 1 ? 's' : ''}
        <span class="muted small">— ${C.pendingPicks.map((g) =>
          `${g.count} ${g.kind === 'secondary' ? 'secondary' : 'related'} at level ${g.granted_at_level}`).join(', ')}</span></h3>
      <button class="btn" onclick="C.claiming = true; render()">Choose now</button>
    </div>`;
  }
  return `
  <div class="levelup noprint">
    ${pickerBlock(C.pendingPicks.map((g) => ({
      level: g.granted_at_level, count: g.count, categories: g.categories,
      // `kind` was dropped here, which is why the banked picker was the worst
      // affected: pickerBlock could not tell a secondary grant from a related
      // one and treated the whole block as unrestricted. F30.
      kind: g.kind,
    })), n, 'claim')}
    <div class="rowline" style="margin-top:10px">
      <button class="btn btn-primary" onclick="claimPicks()">Add to sheet</button>
      <button class="btn btn-sm btn-ghost" onclick="C.claiming = false; C.pickShowAll = false; C.pickFilter = ''; C.pickValues = {}; C.pickLangs = {}; render()">Later</button>
    </div>
  </div>`;
}

// Shared by the level-up panel and the standalone claim on the sheet, so the
// two ways of spending a pick look and behave the same.
//
// Skipping is deliberately free: the picks are banked either way, so nobody is
// stuck at the table choosing skills before they can carry on playing.
function pickerBlock(grants, total, prefix) {
  // Related and secondary grants are kept APART, exactly as the server keeps
  // them (picks.js, level-confirm.js). A secondary grant carries
  // `categories: null`, so folding it in makes `some(g => !g.categories)` true
  // and unrestricts every slot — which is what this did until F30. One banked
  // secondary pick offered the whole catalog for all three slots while the
  // server accepted exactly one out-of-category choice and refused the second
  // with a 422, after it had been made.
  //
  // `kind !== 'secondary'`, not `kind === 'related'`: a grant banked before that
  // column existed carries kind NULL, and the server counts those as related.
  // Testing for 'related' would silently reclassify every older grant as
  // unrestricted — the same bug again, from the other side.
  const related = grants.filter((g) => g.kind !== 'secondary');
  const secondaryAllowance = grants
    .filter((g) => g.kind === 'secondary')
    .reduce((n, g) => n + g.count, 0);
  const allowed = related.some((g) => !g.categories)
    ? null
    : [...new Set(related.flatMap((g) => g.categories || []))];
  // The last `secondaryAllowance` rows draw from the whole catalog. Every
  // submission this can produce is one the server accepts: it permits that many
  // picks outside the related categories, and an in-category choice made in one
  // of those rows is simply in-category to it.
  const restricted = Math.max(0, total - secondaryAllowance);

  const held = new Set((C.data.skills || []).map((s) => s.name));
  const showAll = C.pickShowAll;
  const unheld = (C.skillCatalog || []).filter((s) => !held.has(s.name));
  // categoryAllows, not a plain `includes` — an entry may be an OBJECT narrowing
  // what it admits, and ten of one live grant's thirteen categories are objects.
  // `includes` would drop all ten and offer three categories where the class
  // grants thirteen. Same helper as the server, the wizard and the validator.
  const admits = (s) => (globalThis.skillCats
    ? globalThis.skillCats.categoryAllows(allowed, s)
    : allowed.includes(s.category));
  const pool = unheld.filter((s) => showAll || !allowed || admits(s));

  // One filter feeding every dropdown in the block, because they draw from one
  // pool — you are picking N different skills out of the same 128, not
  // searching N times. Narrowing them together is what you actually want.
  const shown = Picker.filter(pool, C.pickFilter);
  const options = shown
    .map((s) => `<option value="${escHtml(s.name)}">${escHtml(s.name)} — ${escHtml(s.category || '?')} ${s.base}%</option>`)
    .join('');
  // The unrestricted rows get their own list: everything not already held.
  const shownAny = Picker.filter(unheld, C.pickFilter);
  const optionsAny = shownAny
    .map((s) => `<option value="${escHtml(s.name)}">${escHtml(s.name)} — ${escHtml(s.category || '?')} ${s.base}%</option>`)
    .join('');

  const hiddenCount = allowed && !showAll
    ? unheld.filter((s) => !admits(s)).length
    : 0;

  // Selections live in state, not in the DOM. They used to be read off the
  // <select>s only at submit time, so any re-render in between silently threw
  // them away — the "show all skills" checkbox already did that, and a filter
  // that re-renders on every keystroke would do it constantly.
  const rows = Array.from({ length: total }, (_, i) => {
    const chosen = C.pickValues[`${prefix}-${i}`] || '';
    // Rows past the related allowance are the secondary ones and are NOT
    // filtered by category. Labelled, because a row that silently offers more
    // than its neighbour is the confusing half of F30 rather than the fixed one.
    const isSecondary = i >= restricted;
    const rowShown = isSecondary ? shownAny : shown;
    const rowOptions = isSecondary ? optionsAny : options;
    // A skill you have already chosen stays in its own dropdown even when the
    // filter excludes it, or narrowing the list would un-pick it.
    const extra = chosen && !rowShown.some((s) => s.name === chosen)
      ? `<option value="${escHtml(chosen)}" selected>${escHtml(chosen)}</option>` : '';
    const opts = rowOptions.replace(`value="${escHtml(chosen)}"`, `value="${escHtml(chosen)}" selected`);
    // Language: Other and Literacy: Other are each one catalog row standing for
    // every unlisted member of their family; choosing one asks WHICH, and the
    // composed name is what gets submitted (see js/language-skills.js). Same
    // state-not-DOM rule as the select: a re-render must not eat a half-typed
    // language.
    const isOther = langSkills.isRepeatableRow(chosen);
    const lang = C.pickLangs[`${prefix}-${i}`] || '';
    return `
    <div class="rowline">
      <select id="${prefix}-pick-${i}" onchange="C.pickValues['${prefix}-${i}'] = this.value; render()">
        <option value="">— skip —</option>${extra}${chosen ? opts : rowOptions}</select>
      ${isSecondary ? '<span class="muted small">secondary — any category</span>' : ''}
      ${isOther ? `<input class="mini-in wide" id="${prefix}-lang-${i}"
        placeholder="${chosen === langSkills.LITERACY_OTHER ? 'Which written language?' : 'Which language?'}"
        value="${escHtml(lang)}" oninput="C.pickLangs['${prefix}-${i}'] = this.value">` : ''}
    </div>`;
  }).join('');

  return `
  <h2 class="sub-h" style="margin-bottom:4px">New skill${total > 1 ? 's' : ''} — ${total} to choose</h2>
  <p class="muted small" style="margin-top:0">
    ${grants.map((g) => `${g.count} ${g.kind === 'secondary' ? 'secondary' : 'related'} from level ${g.level}`).join(', ')}.
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
    if (langSkills.isRepeatableRow(v)) {
      // Composed or skipped: an Other pick with no language typed waits, the
      // same way a blank row does.
      const full = langSkills.familySkillName(v, C.pickLangs[`${prefix}-${i}`]);
      if (full) picks.push({ name: full, override: !!C.pickShowAll });
    } else if (v) picks.push({ name: v, override: !!C.pickShowAll });
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
  const power_picks = collectPowerPicks();
  try {
    await api(`characters/${id}/level-confirm`, jsonReq('POST', {
      to_level: p.to_level, pools, skills, grants: p.grants, picks, power_picks,
    }));
    C.proposal = null;
    C.pickShowAll = false;
    C.pickFilter = ''; C.pickValues = {}; C.pickLangs = {};
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
    C.pickFilter = ''; C.pickValues = {}; C.pickLangs = {};
    C.claiming = false;
    await load();
    flash(`Added ${res.applied.map((a) => a.name).join(', ')}.`);
  } catch (err) { flash('Could not add: ' + err.message, true); }
}

// Spend PPE/ISP on a power — client-side arithmetic + the existing PATCH
// endpoint (server still enforces owner/GM on the PATCH itself).
// Open or close one power's description. Toggles the element rather than
// re-rendering: a re-render rebuilds every input on the sheet, and the one
// thing a press must never cost a player is a half-typed note — the same
// reason switching tabs toggles classes. The state is recorded so a render
// triggered by something else puts it back.
function togglePowerDesc(index) {
  // NOT `box`: js/sheet-layout.js exports a `box` helper and the smoke test
  // fails a sheet.js that redefines one of its names, drift being how the two
  // files came apart last time.
  const descEl = document.getElementById('pdesc-' + index);
  if (!descEl) return;
  const opening = descEl.hasAttribute('hidden');
  if (opening) descEl.removeAttribute('hidden');
  else descEl.setAttribute('hidden', '');
  if (opening) C.openPowerDescs.add(index);
  else C.openPowerDescs.delete(index);
  const btn = document.querySelector('[aria-controls="pdesc-' + index + '"]');
  if (btn) btn.setAttribute('aria-expanded', String(opening));
}

// The inventory twin of togglePowerDesc. Keyed on the character_items id rather
// than an array index, because the inventory table is repainted on its own by
// refreshInventory() and the rows can be re-ordered under it - an index would
// open the wrong item after an add.
function toggleItemDesc(itemId) {
  const row = document.getElementById('idesc-' + itemId);
  if (!row) return;
  const opening = row.hasAttribute('hidden');
  if (opening) row.removeAttribute('hidden');
  else row.setAttribute('hidden', '');
  if (opening) C.openItemDescs.add(itemId);
  else C.openItemDescs.delete(itemId);
  const btn = document.querySelector('[aria-controls="idesc-' + itemId + '"]');
  if (btn) btn.setAttribute('aria-expanded', String(opening));
}

async function usePower(index) {
  const p = (C.data.powers || [])[index];
  if (!p || typeof p.cost !== 'number') return;
  const pool = p.type === 'spell' ? 'ppe' : 'isp';
  const cur = C.data[pool + '_current'];
  if (cur == null) return;
  if (cur < p.cost) { alert(`Not enough ${pool === 'ppe' ? 'P.P.E.' : 'I.S.P.'} (${cur} left, ${p.name} costs ${p.cost}).`); return; }
  const label = pool === 'ppe' ? 'P.P.E.' : 'I.S.P.';

  // THE SHEET LENS IS UNCHANGED: write, then reload the page around it. There
  // is no queue outside play mode and nothing here is optimistic.
  if (!C.playMode) {
    try {
      await api('characters/' + id, jsonReq('PATCH', { [pool + '_current']: cur - p.cost }));
      C.data[pool + '_current'] = cur - p.cost;
      await load();
    } catch (err) { alert('Failed: ' + err.message); }
    return;
  }

  // AT THE TABLE IT IS OPTIMISTIC NOW, like every other press in play mode. It
  // used to await the write before deducting, which made it the one play action
  // a dropped connection silently swallowed: the spell was cast, the table
  // moved on, and the sheet still showed the P.P.E. unspent. The cost comes off
  // first and the write follows it.
  const next = cur - p.cost;
  const note = `${p.name} −${p.cost} ${label}`;
  const spent = { [pool + '_current']: { from: cur, to: next } };
  C.data[pool + '_current'] = next;
  paintPool(pool);
  // Spending is the commonest way to make the next ⚡ unaffordable, and play
  // mode never re-renders, so the buttons are re-read here.
  syncPowerBtns();
  const logSpend = () => recordRoll('power', p.name,
    { die: 0, roll: 0, target: null, ok: null, note: `-${p.cost} ${label}` });
  try {
    await postEvent('power', note, { character: spent });
    logSpend();
  } catch (err) {
    if (err.status === undefined && await queueChange('power', note, spent)) {
      logSpend();
      renderQueueState();
      return;
    }
    C.data[pool + '_current'] = cur;
    paintPool(pool);
    syncPowerBtns();
    alert('Failed: ' + err.message);
  }
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

// An enchantment slug resolved against the catalog. Returns null rather than a
// placeholder for a slug nothing defines: a row that says "demon-slayer" is
// worse than a row that says nothing, because it looks like a name.
function enchantBySlug(slug) {
  return (C.enchantCatalog || []).find((e) => e.slug === slug) || null;
}

// What an enchantment adds, in the sheet's own words. `bonuses` is the same
// block a class or a skill uses, so this reads combat and saves the same way
// everything else does - flat numbers and dice both, since the Thunder Hammer's
// extra damage is 2D6 and not a 2.
function enchantEffect(e) {
  const bits = [];
  for (const group of ['combat', 'saves', 'attributes']) {
    for (const [k, v] of Object.entries(e.bonuses?.[group] || {})) {
      const n = typeof v === 'number' ? (v >= 0 ? `+${v}` : String(v)) : `+${v}`;
      bits.push(`${n} ${k.replace(/_/g, ' ')}`);
    }
  }
  return bits.join(', ');
}

// The enchantments an inventory row carries, under its name.
//
// Read-only for a player and editable by whoever can write the sheet, which is
// the owner or the GM - the same rule qty and equipped already follow. Nothing
// here invents a number: an enchantment with no `bonuses` shows its name alone,
// because most of them are abilities rather than modifiers and a number would
// be a lie about what the book grants.
function enchantHtml(it) {
  const slugs = Array.isArray(it.enchantments) ? it.enchantments : [];
  const rows = slugs.map((slug) => {
    const e = enchantBySlug(slug);
    if (!e) return '';
    const effect = enchantEffect(e);
    const drop = C.canWrite
      ? ` <button class="btn btn-sm btn-ghost" title="Remove this enchantment"
           onclick="removeEnchantment(${it.id}, '${escHtml(slug)}')">✕</button>`
      : '';
    return `<div class="attr-note" style="margin-left:12px">↳ ${escHtml(e.name)}${
      effect ? ` <span class="muted">(${escHtml(effect)})</span>` : ''}${drop}</div>`;
  }).filter(Boolean).join('');

  const add = C.canWrite && (C.enchantCatalog || []).length
    ? `<div style="margin-left:12px"><button class="btn btn-sm btn-ghost"
         onclick="addEnchantment(${it.id})">+ enchantment</button></div>`
    : '';
  return rows + add;
}

// The inventory table's rows. Hoisted for the same reason: an item change
// re-renders this and nothing else.
function inventoryRowsHtml() {
  const w = C.canWrite;
  return C.items.map((it) => {
    const name = escHtml(it.item_name || it.custom_name);
    // `item_slug`, not `item_id` - see isWeapon() for why. Every row on this
    // sheet has been tagged "custom" since migration 046, including the
    // catalog-linked ones, which on production is all of them.
    const kind = it.item_slug ? '<span class="tag">catalog</span>' : '<span class="tag">custom</span>';
    const stats = itemStatsHtml(it);
    // The name becomes the control rather than adding a separate chevron, the
    // same choice the Powers tab made and for the same reason: it is the
    // biggest target in the row and the thing a player is already looking at. A
    // row with nothing to show keeps a plain span, so nothing offers a press
    // that does nothing.
    //
    // Which rows are open is held in state rather than read off the DOM,
    // because plenty of things repaint this table - changing a quantity does -
    // and a stat block that closed itself when you ticked `equipped` would read
    // as a bug. The key is the character_items id, which survives a repaint.
    const open = C.openItemDescs.has(it.id);
    const nameCell = stats
      ? `<button type="button" class="power-toggle" aria-expanded="${open}"
           aria-controls="idesc-${it.id}" onclick="toggleItemDesc(${it.id})">${name}</button>`
      : name;
    const qty = w
      ? `<input type="number" min="1" value="${it.qty}" onchange="patchItem(${it.id}, {qty: this.value})"><span class="print-only">×${it.qty}</span>`
      : `×${it.qty}`;
    const eq = w
      ? `<input type="checkbox" ${it.equipped ? 'checked' : ''} onchange="patchItem(${it.id}, {equipped: this.checked})"><span class="print-only">${it.equipped ? '✔' : '—'}</span>`
      : (it.equipped ? '✔' : '');
    // Same as the wizard's equipment table: the glyph was the whole accessible
    // name, on every row. `name` is already escaped for an attribute - escHtml
    // escapes the quote now - so this needs no second pass.
    const rmLabel = `Remove ${name}`;
    const rm = w ? `<td><button class="btn btn-sm btn-ghost" aria-label="${rmLabel}" title="${rmLabel}"
      onclick="removeItem(${it.id})">✕</button></td>` : '<td></td>';
    // The block is its own row spanning the table rather than living inside the
    // name cell: a stat block in a 5-column table's first column would set the
    // column's width for every other row.
    const statsRow = stats
      ? `<tr class="item-desc-row" id="idesc-${it.id}"${open ? '' : ' hidden'}>
           <td colspan="5">${stats}</td></tr>`
      : '';
    return `<tr><td>${nameCell} ${kind}${enchantHtml(it)}</td><td>${qty}</td><td>${eq}</td>
      <td class="muted small">${escHtml(it.notes || '')}</td>${rm}</tr>${statsRow}`;
  }).join('');
}

// What a held catalog item IS, from the row the sheet already joined. A custom
// item has nothing here and gets no toggle.
//
// This is the gear half of docs/plans/20-power-descriptions.md: the same
// argument, one catalog over. The whole stat block rides with the character -
// 116 held rows across every character on production - so opening one costs no
// request, which is the point when the wifi at somebody's kitchen table does
// not work.
function itemStatsHtml(it) {
  if (!it.item_slug) return '';
  // Only the fields this row actually has; a bedroll should not print an empty
  // A.R. Mirrors the codex's own stat block, deliberately - the same item read
  // in two places should not look like two different items.
  const dmg = it.item_damage && it.item_is_mega_damage && !/M\.?D\.?/i.test(String(it.item_damage))
    ? `${it.item_damage} (M.D.)` : it.item_damage;
  const pairs = [['Damage', dmg], ['Range', it.item_range], ['Payload', it.item_payload],
                 ['Rate of fire', it.item_rate_of_fire], ['A.R.', it.item_ar],
                 ['S.D.C.', it.item_sdc], ['M.D.C.', it.item_mdc],
                 ['Weight', it.item_weight_lbs != null ? `${it.item_weight_lbs} lbs` : null],
                 ['Cost', itemCost(it)]]
    .filter(([, v]) => v != null && String(v).trim() !== '');
  const desc = it.item_description && String(it.item_description).trim();
  if (!pairs.length && !desc) return '';
  return `${pairs.length ? `<dl class="codex-stats">${pairs
      .map(([k, v]) => `<dt>${escHtml(k)}</dt><dd>${escHtml(v)}</dd>`).join('')}</dl>` : ''}
    ${desc ? `<div class="power-desc">${escHtml(desc)}</div>` : ''}
    ${it.item_cost_note ? `<p class="note small">Price: ${escHtml(it.item_cost_note)}</p>` : ''}
    ${it.item_source_book ? `<p class="muted small">${escHtml(it.item_source_book)}</p>` : ''}`;
}

// Credits in Rifts, gold in Palladium Fantasy; a NULL or `both` system is
// unrestricted and reads as credits, the same way every picker treats it. A
// NULL cost is a FINISHED row - books print issued kit and unique artifacts
// with no price at all - so it shows nothing rather than an em dash that reads
// as missing data.
function itemCost(it) {
  if (it.item_cost == null) return null;
  const unit = it.item_system === 'palladium-fantasy' ? 'gold' : 'cr.';
  return `${Number(it.item_cost).toLocaleString('en-US')}${it.item_cost_note ? '+' : ''} ${unit}`;
}

// ── vessels ──
//
// A vessel is not an inventory line, so it does not render as one: it gets its
// own block under the Equipment table, with M.D.C. BY LOCATION, which is the
// thing `gear` never had a shape for and the reason `vehicles` is three tables.
//
// The maxima come from the catalog (`v.locations`) and the damage from the
// character (`v.mdc_current`, keyed by location name). A location absent from
// that object is undamaged, so the input shows the maximum and stores nothing
// until somebody types.

// One location's current M.D.C. against its printed maximum. `mdc` is NULL
// where the book prints a formula instead, and `mdc_note` carries it - so a row
// with no number shows the note and offers no input, rather than inviting
// somebody to track damage against a maximum nobody knows.
function vesselLocationHtml(v, loc) {
  const w = C.canWrite;
  const cur = Object.prototype.hasOwnProperty.call(v.mdc_current || {}, loc.location)
    ? v.mdc_current[loc.location] : null;
  const shown = cur != null ? cur : loc.mdc;
  if (loc.mdc == null) {
    return `<div class="field"><span class="lbl">${escHtml(loc.location)}</span><span class="dots"></span>
      <span class="val muted small">${escHtml(loc.mdc_note || '—')}</span></div>`;
  }
  const val = w
    ? `<input class="mini-in" type="number" value="${escHtml(String(shown ?? ''))}"
         data-vessel="${v.id}" data-loc="${escHtml(loc.location)}"
         onchange="patchVesselMdc(${v.id}, this.dataset.loc, this.value)">`
    : escHtml(String(shown ?? '—'));
  // The maximum is printed beside the input rather than as a placeholder: a
  // placeholder disappears the moment anything is typed, and "180 of 270" is
  // the number a player needs while the armour is coming apart.
  return `<div class="field"><span class="lbl">${escHtml(loc.location)}</span><span class="dots"></span>
    <span class="val">${val} <span class="muted small">of ${loc.mdc}</span></span></div>`;
}

function vesselHtml(v) {
  const w = C.canWrite;
  const name = v.vehicle_name || v.custom_name;
  const open = C.openVessels.has(v.id);
  const kind = v.vehicle_slug ? '<span class="tag">catalog</span>' : '<span class="tag">custom</span>';
  const cls = v.vehicle_class ? `<span class="muted small">${escHtml(v.vehicle_class)}</span>` : '';
  const locs = (v.locations || []).filter((l) => l.mdc != null || l.mdc_note);
  const weps = v.weapons || [];
  const rm = w ? `<button class="btn btn-sm btn-ghost noprint" aria-label="Remove ${escHtml(name)}"
      title="Remove ${escHtml(name)}" onclick="removeVessel(${v.id})">✕</button>` : '';

  return `<div class="vessel${open ? ' open' : ''}">
    <div class="vessel-head">
      <button type="button" class="power-toggle" aria-expanded="${open}" aria-controls="vessel-${v.id}"
        onclick="toggleVessel(${v.id})">${escHtml(v.nickname || name)}</button>
      ${v.nickname ? `<span class="muted small">${escHtml(name)}</span>` : ''}
      ${kind} ${cls}${rm}
    </div>
    <div id="vessel-${v.id}"${open ? '' : ' hidden'}>
      ${locs.length ? `<div class="codex-sub">M.D.C. by location</div>
        ${locs.map((l) => vesselLocationHtml(v, l)).join('')}` : ''}
      ${weps.length ? `<div class="codex-sub">Weapon systems</div>
        ${weps.map((wp) => {
          const bits = [['Damage', wp.damage], ['Range', wp.range], ['Rate of fire', wp.rate_of_fire],
                        ['Payload', wp.payload], ['Bonus', wp.bonus]]
            .filter(([, x]) => x != null && String(x).trim() !== '');
          return `<div class="codex-weapon">
            <div class="codex-weapon-name">${wp.ordinal != null ? escHtml(wp.ordinal + '. ') : ''}${escHtml(wp.name)}</div>
            ${bits.length ? `<dl class="codex-stats">${bits.map(([k, x]) =>
              `<dt>${escHtml(k)}</dt><dd>${escHtml(x)}</dd>`).join('')}</dl>` : ''}
          </div>`;
        }).join('')}` : ''}
      ${v.notes ? `<p class="note small">${escHtml(v.notes)}</p>` : ''}
      ${v.vehicle_source_book ? `<p class="muted small">${escHtml(v.vehicle_source_book)}</p>` : ''}
    </div>
  </div>`;
}

function vesselsHtml() {
  const rows = (C.vehicles || []).map(vesselHtml).join('');
  return rows || '<p class="muted small">No vessel.</p>';
}

function toggleVessel(vid) {
  // NOT `box`: js/sheet-layout.js exports a helper of that name and the smoke
  // test fails a sheet.js that redefines one of its names, drift being how the
  // two files came apart last time. togglePowerDesc carries the same warning.
  const panel = document.getElementById('vessel-' + vid);
  if (!panel) return;
  const opening = panel.hasAttribute('hidden');
  if (opening) panel.removeAttribute('hidden'); else panel.setAttribute('hidden', '');
  if (opening) C.openVessels.add(vid); else C.openVessels.delete(vid);
  const btn = document.querySelector('[aria-controls="vessel-' + vid + '"]');
  if (btn) btn.setAttribute('aria-expanded', String(opening));
}

// The picker's list, fetched once and only when somebody opens the control.
// `vehicles-index` is name and class only - about 10 KB, against 106.8 KB for
// the section carrying every location and weapon system. Putting 127 names in a
// dropdown does not need 1,238 location rows.
async function loadVesselCatalog() {
  if (C.vesselCatalog) return C.vesselCatalog;
  try {
    const res = await api('codex?section=vehicles-index');
    C.vesselCatalog = res['vehicles-index'] || [];
  } catch { C.vesselCatalog = []; }
  return C.vesselCatalog;
}

async function openVesselPicker() {
  const list = await loadVesselCatalog();
  const sel = $('add-vessel');
  if (!sel) return;
  if (!list.length) { sel.innerHTML = '<option value="">— none available —</option>'; return; }
  sel.innerHTML = '<option value="">— catalog —</option>' + list.map((v) =>
    `<option value="${escHtml(v.slug)}">${escHtml(v.name)}${
      v.vehicle_class ? ` (${escHtml(v.vehicle_class)})` : ''}</option>`).join('');
}

async function addVessel() {
  const slug = $('add-vessel')?.value || '';
  const custom = $('add-vessel-name')?.value.trim() || '';
  const nickname = $('add-vessel-nick')?.value.trim() || '';
  if (!slug && !custom) { alert('Pick a vessel from the catalog, or type a name.'); return; }
  try {
    await api('characters/' + id + '/vehicles',
      jsonReq('POST', slug ? { slug, nickname } : { custom_name: custom, nickname }));
    await refreshVessels();
  } catch (err) { alert('Failed: ' + err.message); }
}

async function removeVessel(vid) {
  if (!confirm('Remove this vessel? (History is kept.)')) return;
  try {
    await api('characters/' + id + '/vehicles/' + vid, jsonReq('DELETE', undefined));
    await refreshVessels();
  } catch (err) { alert('Failed: ' + err.message); }
}

// One location's damage. Sent as the whole object rather than a patch of one
// key, because that is the column's shape - and read from the DOM rather than
// from state, so two inputs edited before either round-trips do not overwrite
// each other with a stale copy.
async function patchVesselMdc(vid, location, value) {
  const v = (C.vehicles || []).find((x) => x.id === vid);
  if (!v) return;
  const next = { ...(v.mdc_current || {}) };
  const n = parseInt(value, 10);
  if (Number.isFinite(n)) next[location] = n; else delete next[location];
  try {
    await api('characters/' + id + '/vehicles/' + vid, jsonReq('PATCH', { mdc_current: next }));
    v.mdc_current = next;
  } catch (err) { alert('Failed: ' + err.message); }
}

// Repaint only the vessel block, for the reason refreshInventory exists: a full
// load() would replace C.data and discard anything typed into the sheet.
async function refreshVessels() {
  const res = await api('characters/' + id);
  C.vehicles = res.vehicles || [];
  const list = $('vessel-list');
  if (list) list.innerHTML = vesselsHtml();
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
  // Which version this tab believes it is changing. Two people on one
  // character - a player and a G.M. at the same table, or the same person in
  // two tabs - used to overwrite each other silently, last write winning with
  // nothing said. The server refuses a write against a version that has moved.
  body.expect_updated_at = C.data?.updated_at || undefined;
  try {
    const res = await api('characters/' + id, jsonReq('PATCH', body));
    if (res?.updated_at) C.data.updated_at = res.updated_at;
    flash('Saved.');
    await load();
  } catch (err) {
    if (err.status === 409 && err.detail?.conflict) {
      // Nothing was written, so nothing is lost on the server. What is at risk
      // is what is typed on this screen, which is why this asks rather than
      // reloading over it.
      flash('Not saved: this character changed somewhere else since you opened it.', true);
      const msg = 'This character was changed somewhere else. Reload to see the '
        + 'current version? Your unsaved edits on this screen will be lost.';
      if (confirm(msg)) {
        await load();
      }
      return;
    }
    const details = errorDetails(err);
    flash('Save failed: ' + err.message + (details.length ? ' — ' + details.join('; ') : ''), true);
  }
}

async function patchItem(rowId, fields) {
  try { await api(`characters/${id}/items/${rowId}`, jsonReq('PATCH', fields)); await refreshInventory(); }
  catch (err) { alert('Update failed: ' + err.message); }
}

// Add or drop one enchantment on one inventory row.
//
// The whole array is sent, because that is what the column holds and what the
// server validates - family, the book's cap, and whether an armour feature is
// being put in a sword. Sending a delta would mean the server had to guess at
// the intended end state.
async function addEnchantment(rowId) {
  const it = C.items.find((x) => x.id === rowId);
  if (!it) return;
  const held = Array.isArray(it.enchantments) ? it.enchantments : [];
  const offered = (C.enchantCatalog || []).filter((e) => !held.includes(e.slug));
  if (!offered.length) return alert('Nothing left to add.');
  const menu = offered
    .map((e, i) => `${i + 1}. ${e.name} (${e.applies_to}${e.cost ? `, ${e.cost.toLocaleString()} gold` : ''})`)
    .join('\n');
  const pick = window.prompt(`Which enchantment?\n\n${menu}\n\nNumber:`);
  const n = parseInt(pick, 10);
  if (!Number.isFinite(n) || n < 1 || n > offered.length) return;
  await patchItem(rowId, { enchantments: [...held, offered[n - 1].slug] });
}

async function removeEnchantment(rowId, slug) {
  const it = C.items.find((x) => x.id === rowId);
  if (!it) return;
  const held = Array.isArray(it.enchantments) ? it.enchantments : [];
  await patchItem(rowId, { enchantments: held.filter((sl) => sl !== slug) });
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

  // data-box and data-col by hand, because this box is built by hand. It had
  // neither until the column stacks went in, which meant it placed on `auto`
  // and sat whereever the grid had room - beside Attributes by luck, not by
  // decision. BOX_COL stays the one place a column is chosen.
  return `<div class="box noprint" data-box="stage" data-col="${BOX_COL.stage}">
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
    <h2 class="sub-h" style="margin-top:0">${escHtml(p.from_name || 'Current')} → ${escHtml(p.to_name)}</h2>
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
