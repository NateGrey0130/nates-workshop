// The G.M.'s statted NPCs - the list, and the three ways to add one: roll from
// a class, place a notable NPC from the books, roll creatures from the books.
//
// ONE COPY, TWO PAGES. This panel was written into the campaign page's People
// tab (apps/campaign/campaign.js); GM Tools needed the same abilities, and a
// second copy is the thing that drifts - a fix to one roller that the other
// never gets. So it lives here, and both pages mount it. The People tab keeps
// its panel.
//
// It renders into ITS OWN container and repaints only that. GM Tools rebuilds
// its whole page on a full render, which would throw away a half-typed G.M.
// note; a panel that owned the page's render could not be mounted there.
//
// Everything here is G.M.-only, and the server is what makes it so: the roster
// request sends kind = 'npc' rows to the campaign's G.M. alone (isHiddenNpc),
// and every write below is requireCampaign(..., { gm: true }). A page mounts
// the panel only for the G.M., which saves requests - it is not the guard.
//
// A classic script, like campaign-list.js: escHtml()/escJs() from
// /shared/js/ui.js, api() from js/api.js.
'use strict';

window.npcSheets = (function () {
  const S = {
    host: null,          // { campaignId, system, containerId, classNames, onRoster(list), dossiers? }
    roster: [],
    dossiers: null,      // the campaign's dossiers, for the link control; null = not offered
    gen: { open: false, classes: null, cls: '', occ: '', level: 1, count: 1, name: '', each: false,
           busy: false, msg: '', err: false },
    book: { open: false, rows: null, slug: '', name: '', q: '', src: '', all: false,
            busy: false, msg: '', err: false },
    beast: { open: false, rows: null, slug: '', count: 1, name: '', q: '', src: '', all: false,
             busy: false, msg: '', err: false },
  };
  const esc = (s) => escHtml(s == null ? '' : String(s));
  const cid = () => S.host.campaignId;

  function mount(host) {
    S.host = host;
    S.roster = host.roster || [];
    S.dossiers = host.dossiers || null;
    return `<div id="${host.containerId}">${html()}</div>`;
  }
  function render() {
    const el = document.getElementById(S.host.containerId);
    if (el) el.innerHTML = html();
  }
  function setRoster(list) { S.roster = list || []; render(); }
  function setDossiers(list) { S.dossiers = list; render(); }

  async function reloadRoster() {
    const list = (await api(`characters?campaign_id=${cid()}`)).characters || [];
    S.roster = list;
    S.host.onRoster?.(list);
  }

  const sheets = () => S.roster.filter((c) => c.kind === 'npc');

  // A book NPC's class id is `notable:<slug>` (from-notable) - it names where
  // the sheet came from, not a class, so it reads as that. A creature's is
  // `creature:<slug>` (from-creature), for the same reason.
  const className = (id) => (String(id).startsWith('notable:') ? 'from the books'
    : String(id).startsWith('creature:') ? 'a creature from the books'
    : S.host.classNames?.[id] || id);

  function html() {
    const list = sheets();
    return `<div class="panel">
      <h3>Statted NPCs <span class="muted small">— only you can see these</span></h3>
      ${S.gen.open ? genForm() : S.book.open ? pickForm('book') : S.beast.open ? pickForm('beast')
        : `<div class="rowline" style="margin-top:6px;flex-wrap:wrap">
            <button class="btn btn-sm" onclick="npcSheets.openGen()">🎲 Roll NPCs from a class</button>
            <button class="btn btn-sm" onclick="npcSheets.openPick('book')">📖 Place a notable NPC from the books</button>
            <button class="btn btn-sm" onclick="npcSheets.openPick('beast')">🐾 Roll creatures from the books</button></div>`}
      <div style="margin-top:10px">${list.length ? list.map(sheetRow).join('')
        : '<p class="muted small">None yet. Roll some, then link one to a dossier.</p>'}</div>
    </div>`;
  }

  // The dossier a sheet is linked to, and a control to change it. A dossier is
  // what the table knows about someone; linking one says which statted sheet
  // is the truth behind it (npcs.character_id, migration 071).
  function linkControl(c) {
    if (!S.dossiers) return '';
    const linked = S.dossiers.find((n) => n.character_id === c.id);
    return `<label class="small muted">dossier
      <select aria-label="Dossier for ${esc(c.name)}" onchange="npcSheets.link(${c.id}, this.value)">
        <option value="">— none —</option>
        ${S.dossiers.map((n) => `<option value="${n.id}"${linked?.id === n.id ? ' selected' : ''}${
          n.character_id && n.character_id !== c.id ? ' disabled' : ''}>${esc(n.name)}</option>`).join('')}
      </select></label>`;
  }

  function sheetRow(c) {
    return `<div class="chkrow">
      <span><a href="/apps/character-sheet/?id=${c.id}"><b>${esc(c.name)}</b></a>
        <span class="muted small"> — ${esc(className(c.class_id))}${
          c.occ_class_id ? ' ' + esc(className(c.occ_class_id)) : ''}, level ${c.level}</span></span>
      <span class="rowline" style="flex-wrap:wrap">
        ${linkControl(c)}
        <a class="btn btn-sm btn-ghost" href="/apps/character-sheet/?id=${c.id}&amp;play=1">▶ Play</a>
        <button class="btn btn-sm btn-ghost" onclick="npcSheets.remove(${c.id})">delete</button>
      </span>
    </div>`;
  }

  // ---------- roll from a class ----------

  // A race whose entry grants no related or secondary skills takes an
  // occupation, and the server refuses one without it - so the form asks rather
  // than letting the refusal be the first the G.M. hears of it. The same test
  // js/parser.js needsOccupation() applies.
  const takesOccupation = (c) => c?.category === 'rcc'
    && !(c.skills?.occ_related_skills?.count) && !(c.skills?.secondary_skills?.count);

  function genForm() {
    const g = S.gen;
    if (!g.classes) return '<p class="muted small" style="margin-top:10px">Loading classes…</p>';
    const option = (c, sel) => `<option value="${esc(c.id)}"${c.id === sel ? ' selected' : ''}>${esc(c.name)}</option>`;
    const races = g.classes.filter((c) => c.category === 'rcc');
    const jobs = g.classes.filter((c) => c.category !== 'rcc');
    const chosen = g.classes.find((c) => c.id === g.cls);
    const needsJob = takesOccupation(chosen);
    return `<div class="panel-inset" style="margin-top:10px">
      <div class="rowline" style="flex-wrap:wrap">
        <label class="small">Class
          <select onchange="npcSheets.genSet('cls', this.value, true)">
            <option value="">— choose —</option>
            <optgroup label="Races (R.C.C.)">${races.map((c) => option(c, g.cls)).join('')}</optgroup>
            <optgroup label="Occupations (O.C.C.)">${jobs.map((c) => option(c, g.cls)).join('')}</optgroup>
          </select></label>
        ${chosen?.category === 'rcc' ? `<label class="small">Occupation${needsJob ? '' : ' <span class="muted">(optional)</span>'}
          <select onchange="npcSheets.genSet('occ', this.value, true)">
            <option value="">${needsJob ? '— choose one —' : '— none —'}</option>
            ${jobs.map((c) => option(c, g.occ)).join('')}
          </select></label>` : ''}
      </div>
      <div class="rowline" style="flex-wrap:wrap;margin-top:8px">
        <label class="small">Level <input type="number" min="1" max="20" value="${g.level}" style="width:4.5em"
          onchange="npcSheets.genSet('level', this.value)"></label>
        <label class="small">How many <input type="number" min="1" max="10" value="${g.count}" style="width:4.5em"
          onchange="npcSheets.genSet('count', this.value)"></label>
        <input type="text" id="npcgen-name" class="picker-input" placeholder="Name (optional)" value="${esc(g.name)}"
          ${g.each ? 'disabled' : ''} onchange="npcSheets.genSet('name', this.value)">
        ${window.namePanel ? namePanel.button('npcgen-name', genNameOpts) : ''}
      </div>
      ${window.namePanel ? namePanel.slot('npcgen-name') : ''}
      ${window.namePanel ? `<label class="small" style="display:block;margin-top:6px">
        <input type="checkbox" ${g.each ? 'checked' : ''} onchange="npcSheets.genSet('each', this.checked, true)">
        a different name for each
        <span class="muted">— from the 🎲 theme, none already used in this campaign; the Name box is not used</span></label>` : ''}
      <div class="rowline" style="margin-top:8px">
        <button class="btn btn-sm btn-primary" onclick="npcSheets.roll()"
          ${g.busy || !g.cls || (needsJob && !g.occ) ? 'disabled' : ''}>${g.busy ? 'Rolling…' : 'Roll'}</button>
        <button class="btn btn-sm btn-ghost" onclick="npcSheets.closeGen()">close</button>
      </div>
      <p class="small muted">Every choice is made at random and checked against the class like a
        player's character. Spells and psionic powers the class lets them <em>choose</em> are banked on
        the sheet for you to pick. A class the roller cannot build legally is refused, with the reason.</p>
      ${g.msg ? `<p class="small${g.err ? ' err' : ''}">${esc(g.msg)}</p>` : ''}
    </div>`;
  }

  async function openGen() {
    S.gen.open = true;
    render();
    if (S.gen.classes) return;
    try {
      const res = await api(`classes?system=${encodeURIComponent(S.host.system)}`);
      S.gen.classes = [...res.classes].sort((a, b) => String(a.name).localeCompare(String(b.name)));
    } catch (err) { S.gen.msg = 'Could not load classes: ' + err.message; S.gen.err = true; S.gen.classes = []; }
    render();
  }
  function closeGen() { S.gen.open = false; S.gen.msg = ''; render(); }

  // Selects re-render (the occupation control appears with a race, and the Roll
  // button waits for one); typed inputs only store, so a keystroke never
  // rebuilds the field being typed in.
  function genSet(key, value, rerender = false) {
    const g = S.gen;
    if (key === 'level') g.level = Math.max(1, Math.trunc(Number(value) || 1));
    else if (key === 'count') g.count = Math.max(1, Math.min(10, Math.trunc(Number(value) || 1)));
    else g[key] = value;
    if (key === 'cls') { g.occ = ''; g.msg = ''; g.err = false; }
    // A new class moves the name theme to that class's own (a Wolfen gets
    // Wolfen names), unless the G.M. has already picked one.
    if ((key === 'cls' || key === 'occ') && window.namePanel) namePanel.classChanged('npcgen-name', genClasses());
    if (rerender) render();
  }

  // What the 🎲 beside the roller's Name box knows about the class chosen.
  const genClasses = () => ({ cls: S.gen.cls, occ: S.gen.occ });
  const genNameOpts = { kinds: ['person'], classes: genClasses };

  async function roll() {
    const g = S.gen;
    g.busy = true; g.msg = ''; g.err = false;
    render();
    try {
      const body = { class_id: g.cls, occ_class_id: g.occ || null, level: g.level, count: g.count };
      // "A different name for each": the theme the 🎲 is on, or the class's
      // default if it was never opened. The server picks every name before it
      // writes anything, and refuses a batch the theme cannot name.
      if (g.each) Object.assign(body, await namePanel.batchOptions('npcgen-name', genClasses()));
      else body.name = g.name.trim() || null;
      const res = await api(`campaigns/${cid()}/npcs/generate`, {
        method: 'POST', headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body),
      });
      await reloadRoster();
      const banked = res.npcs.reduce((n, x) => n + (x.powers_banked || 0) + (x.picks_pending || 0), 0);
      g.msg = `Rolled ${res.npcs.length}: ${res.npcs.map((x) => x.name).join(', ')}.`
        + (banked ? ` ${banked} pick${banked === 1 ? '' : 's'} banked on their sheets for you to choose.` : '')
        + (res.refused ? ` Stopped there: ${res.refused.error}` : '');
      g.err = !!res.refused;
    } catch (err) {
      g.msg = err.message; g.err = true;
    }
    g.busy = false;
    render();
  }

  // ---------- from the books: a notable NPC, or creatures ----------
  //
  // Notable NPCs are named people the books stat; placing one COPIES the book's
  // numbers into this campaign, one-way. Creatures are species; each individual
  // is ROLLED from the book's dice, separately, and a formula the server cannot
  // roll is refused with its name. Both pickers share this code: search by name,
  // narrow by game and by book, and see the stat block before placing it.
  const PICK = {
    book: { section: 'notables', noun: 'notable NPCs', verb: 'Place in this campaign', busyVerb: 'Placing…',
      endpoint: 'from-notable', count: false,
      note: 'The book\'s own numbers for this person, copied. Its attacks, powers and gear go in the sheet\'s notes. Changes to the copy never touch the book.' },
    beast: { section: 'creatures', noun: 'creatures', verb: 'Roll into this campaign', busyVerb: 'Rolling…',
      endpoint: 'from-creature', count: true,
      note: 'Each one is rolled from the book\'s dice. Its attacks and abilities go in the sheet\'s notes. Changes to a creature never touch the book.' },
  };

  // "Rifts Ultimate Edition p.328" is a book and a page; the filter wants the book.
  const bookOf = (s) => String(s || '').replace(/\s+p{1,2}\.\s*[\d\s,–-]+$/i, '').trim() || '(no book)';
  const inGame = (r) => !r.system || r.system === 'both' || r.system === S.host.system;

  function visibleRows(which) {
    const p = S[which];
    const q = p.q.trim().toLowerCase();
    return (p.rows || []).filter((r) => (p.all || inGame(r))
      && (!p.src || bookOf(r.source_book) === p.src)
      && (!q || [r.name, r.real_name, r.title, r.race, r.occ, r.category].some((v) => String(v || '').toLowerCase().includes(q))));
  }

  function optionsHtml(which) {
    const p = S[which];
    const rows = visibleRows(which);
    if (!rows.length) return '<option value="" disabled>— nothing matches —</option>';
    return rows.map((r) => `<option value="${esc(r.slug)}"${r.slug === p.slug ? ' selected' : ''}>${
      esc(r.name)}${r.title ? ` — ${esc(r.title)}` : r.category ? ` — ${esc(r.category)}` : ''}${
      p.all && r.system ? ` [${esc(r.system)}]` : ''} (${esc(r.source_book || '')})</option>`).join('');
  }

  function pickForm(which) {
    const p = S[which];
    const cfg = PICK[which];
    if (!p.rows) return '<p class="muted small" style="margin-top:10px">Loading the books…</p>';
    const books = [...new Set(p.rows.filter((r) => p.all || inGame(r)).map((r) => bookOf(r.source_book)))].sort();
    const n = visibleRows(which).length;
    return `<div class="panel-inset" style="margin-top:10px">
      <div class="rowline" style="flex-wrap:wrap">
        <input type="search" class="picker-input" placeholder="Search ${cfg.noun} by name" value="${esc(p.q)}"
          aria-label="Search ${cfg.noun}" oninput="npcSheets.pickSearch('${which}', this.value)">
        <label class="small" style="max-width:100%;min-width:0">Book <select style="max-width:100%"
          onchange="npcSheets.pickSet('${which}', 'src', this.value)">
          <option value="">every book</option>
          ${books.map((b) => `<option value="${esc(b)}"${b === p.src ? ' selected' : ''}>${esc(b)}</option>`).join('')}
        </select></label>
        <label class="small"><input type="checkbox" ${p.all ? 'checked' : ''}
          onchange="npcSheets.pickSet('${which}', 'all', this.checked)"> every game, not only ${esc(S.host.system)}</label>
      </div>
      ${/* The list takes the whole row: an option carries name, title and citation,
           and a select sized to its longest option overran the panel on desktop. */ ''}
      <label class="small" style="display:block;margin-top:8px">From the books
        <span class="muted" id="${S.host.containerId}-${which}-n">(${n})</span>
        <select id="${S.host.containerId}-${which}-list" size="6" style="width:100%"
          onchange="npcSheets.pickSet('${which}', 'slug', this.value)">${optionsHtml(which)}</select></label>
      ${p.slug ? preview(p.rows.find((r) => r.slug === p.slug), which) : ''}
      <div class="rowline" style="flex-wrap:wrap;margin-top:8px">
        ${cfg.count ? `<label class="small">How many
          <input type="number" min="1" max="12" value="${p.count}" style="width:5em"
            onchange="npcSheets.pickSet('${which}', 'count', this.value)"></label>` : ''}
        <input type="text" id="npc${which}-name" class="picker-input" placeholder="Name in this campaign (optional)"
          value="${esc(p.name)}" onchange="npcSheets.pickSet('${which}', 'name', this.value)">
        ${window.namePanel ? namePanel.button(`npc${which}-name`, { kinds: ['person'] }) : ''}
      </div>
      ${window.namePanel ? namePanel.slot(`npc${which}-name`) : ''}
      <div class="rowline" style="margin-top:8px">
        <button class="btn btn-sm btn-primary" onclick="npcSheets.place('${which}')" ${p.busy || !p.slug ? 'disabled' : ''}>
          ${p.busy ? cfg.busyVerb : cfg.verb}</button>
        <button class="btn btn-sm btn-ghost" onclick="npcSheets.closePick('${which}')">close</button>
      </div>
      <p class="small muted">${cfg.note}</p>
      ${p.msg ? `<p class="small${p.err ? ' err' : ''}">${esc(p.msg)}</p>` : ''}
    </div>`;
  }

  // The stat block, before it is placed: what the G.M. would otherwise open the
  // codex to check. A creature's attributes are DICE; a notable's are numbers.
  const ATTRS = ['IQ', 'ME', 'MA', 'PS', 'PP', 'PE', 'PB', 'Spd'];
  const POOLS = [['hp', 'H.P.'], ['sdc', 'S.D.C.'], ['mdc', 'M.D.C.'], ['ppe', 'P.P.E.'], ['isp', 'I.S.P.'],
                 ['ar', 'A.R.'], ['horror_factor', 'Horror Factor']];
  function preview(r, which) {
    if (!r) return '';
    const a = r.attributes || {};
    const attrs = ATTRS.filter((k) => a[k] != null && a[k] !== '').map((k) => `${k} ${esc(a[k])}`).join(' · ');
    const pools = POOLS.filter(([k]) => r[k] != null && r[k] !== '').map(([k, l]) => `${l} ${esc(r[k])}`).join(' · ');
    const who = [r.real_name && r.real_name !== r.name ? r.real_name : null, r.race, r.occ,
      r.level ? `level ${r.level}` : null, r.alignment].filter(Boolean).map(esc).join(' · ');
    // The printed damage usually says "M.D." already; the flag adds it only
    // where the book's text does not.
    const attacks = (r.attacks || []).slice(0, 6).map((x) => `${esc(x.name)}${x.damage ? ' ' + esc(x.damage) : ''}${
      x.is_mega_damage && !/M\.?D\b/.test(x.damage || '') ? ' M.D.' : ''}`).join('; ');
    return `<div class="small npc-preview" style="margin-top:8px;padding:8px;border:1px solid var(--border, #ccc)">
      <b>${esc(r.name)}</b>${r.title ? ` <span class="muted">${esc(r.title)}</span>` : ''}
      ${who ? `<div class="muted">${who}</div>` : ''}
      ${attrs ? `<div>${which === 'beast' ? 'Dice: ' : ''}${attrs}</div>` : ''}
      ${pools ? `<div>${pools}</div>` : ''}
      ${attacks ? `<div>Attacks: ${attacks}${(r.attacks || []).length > 6 ? '; …' : ''}</div>` : ''}
    </div>`;
  }

  async function openPick(which) {
    S[which].open = true;
    render();
    if (S[which].rows) return;
    try {
      S[which].rows = (await api(`codex?section=${PICK[which].section}`))[PICK[which].section] || [];
    } catch (err) { S[which].msg = 'Could not load them: ' + err.message; S[which].err = true; S[which].rows = []; }
    render();
  }
  function closePick(which) { S[which].open = false; S[which].msg = ''; render(); }

  // Typing repaints the list and its count only, so the search box keeps focus.
  function pickSearch(which, value) {
    S[which].q = value;
    const list = document.getElementById(`${S.host.containerId}-${which}-list`);
    const n = document.getElementById(`${S.host.containerId}-${which}-n`);
    if (list) list.innerHTML = optionsHtml(which);
    if (n) n.textContent = `(${visibleRows(which).length})`;
  }
  function pickSet(which, key, value) {
    const p = S[which];
    if (key === 'count') p.count = Math.max(1, Math.min(12, Math.trunc(Number(value) || 1)));
    else p[key] = value;
    if (key === 'slug' || key === 'src' || key === 'all') { p.msg = ''; p.err = false; }
    if (key !== 'name' && key !== 'count') render();
  }

  async function place(which) {
    const p = S[which];
    const cfg = PICK[which];
    p.busy = true; p.msg = ''; p.err = false;
    render();
    try {
      const res = await api(`campaigns/${cid()}/npcs/${cfg.endpoint}`, {
        method: 'POST', headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(cfg.count ? { slug: p.slug, count: p.count, name: p.name.trim() || null }
          : { slug: p.slug, name: p.name.trim() || null }),
      });
      await reloadRoster();
      if (cfg.count) {
        const made = res.characters || [];
        p.msg = made.length === 1 ? `Rolled ${made[0].name}.` : `Rolled ${made.length}: ${made.map((c) => c.name).join(', ')}.`;
      } else {
        p.msg = `Placed ${res.name}.`;
      }
      p.name = '';
    } catch (err) { p.msg = err.message; p.err = true; }
    p.busy = false;
    render();
  }

  // ---------- a sheet's own actions ----------

  async function remove(id) {
    if (!confirm('Delete this statted NPC? A dossier linked to it keeps everything but the link.')) return;
    try {
      await api(`characters/${id}`, { method: 'DELETE' });
      await reloadRoster();
      if (S.dossiers) S.dossiers = S.dossiers.map((n) => (n.character_id === id ? { ...n, character_id: null } : n));
      render();
    } catch (err) { alert('Failed: ' + err.message); }
  }

  // Link a sheet to a dossier, moving the link off whichever dossier held it.
  async function link(sheetId, npcId) {
    const was = S.dossiers.find((n) => n.character_id === sheetId);
    try {
      if (was && String(was.id) !== String(npcId)) await patchLink(was.id, null);
      if (npcId) await patchLink(Number(npcId), sheetId);
      S.host.onDossiers?.(S.dossiers);
      render();
    } catch (err) { alert('Failed: ' + err.message); render(); }
  }
  async function patchLink(npcId, characterId) {
    const res = await api(`campaigns/${cid()}/npcs/${npcId}`, {
      method: 'PATCH', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ character_id: characterId }),
    });
    S.dossiers = S.dossiers.map((n) => (n.id === npcId ? { ...n, ...res.npc } : n));
  }

  return { mount, render, setRoster, setDossiers, openGen, closeGen, genSet, roll,
           openPick, closePick, pickSearch, pickSet, place, remove, link, sheets, className };
})();
