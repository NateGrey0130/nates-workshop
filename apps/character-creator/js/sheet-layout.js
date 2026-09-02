// How the character sheet LOOKS: the pool widget, the box and field helpers,
// and the table that decides which column a box lands in.
//
// Loaded as a classic script before sheet.js, like derive.js and rules.js, and
// exposing one global: `sheetLayout`. sheet.js destructures it once so its own
// call sites read the same as they always did.
//
// WHY THIS IS A SEPARATE FILE. sheet.js is 2300 lines of data logic - fetching
// a character, deriving its numbers, saving edits, reconciling play events -
// and these functions are none of that. They take values and return markup.
// Splitting them out means a change to how a pool looks cannot touch how a
// pool is saved, and the diff for a visual change stops arriving mixed in with
// the diff for a behavioural one.
//
// NOTHING HERE READS APPLICATION STATE. paintPool takes the character data as
// an argument rather than reaching for C, which is what keeps this file
// presentation rather than a second place that knows what a character is. The
// one exception is deliberate and visible: the stepper buttons emit
// `C.playAmt` into an onclick attribute, which the page evaluates at click
// time. That is an HTML string, not a dependency of this module.
(function (global) {
  'use strict';

  // Each pool's own colour, spent on the top rule, the bar, and - below a
  // third - the number. The point is that a glance at the strip says WHICH
  // pool is low, not merely that something is. Token names rather than hexes,
  // so the widget follows the palette; styles.css records the measured ratios.
  const POOL_TONES = {
    hp: '--danger', sdc: '--warning', mdc: '--accent-secondary',
    ppe: '--success', isp: '--accent',
  };
  const POOL_LOW = 0.34;

  const fraction = (cur, max) =>
    (max > 0 && cur != null) ? Math.max(0, Math.min(1, cur / max)) : 0;

  // ONE pool widget, used by the sheet and by play mode. The block comment
  // over .vital in styles.css says why the value is two nodes rather than one;
  // the short version is that seven mutation paths write to the <b> by id with
  // .textContent, and an input would have swallowed every one of them.
  //
  //   w        can this viewer write
  //   stepper  offer the +/- pair. CSS still gates it on body.play-mode, so a
  //            sheet-mode render cannot leak steppers even if this is true.
  function poolCard(key, label, cur, max, w, stepper) {
    if (max == null && cur == null) return '';
    const pct = fraction(cur, max);
    const low = max > 0 && cur != null && pct <= POOL_LOW;
    return `<div class="vital${low ? ' low' : ''}" style="--tone: var(${POOL_TONES[key]})">
    <div class="lbl">${label}</div>
    <div class="val">${w ? `<input type="number" id="stat-${key}" value="${cur ?? ''}">` : ''}<b id="play-cur-${key}">${cur ?? '—'}</b> <span class="max">/ ${max ?? '—'}</span></div>
    <div class="bar"><i style="width:${Math.round(pct * 100)}%"></i></div>
    ${stepper && w ? `<div class="steppers">
      <button type="button" aria-label="${label} down" onclick="adjustPool('${key}', -C.playAmt)">−</button>
      <button type="button" aria-label="${label} up" onclick="adjustPool('${key}', C.playAmt)">+</button>
    </div>` : ''}
  </div>`;
  }

  // Paint one pool from the character data it is handed: the number, the bar,
  // the low tone and the input. PLAY MODE NEVER RE-RENDERS, so every path that
  // changes a pool calls this rather than writing the number by hand. Writing
  // the number alone was enough while the widget was only a number; now that
  // it carries a bar, a half-update leaves the bar at its render-time width -
  // measured, not theorised: H.P. at 4 of 14 still drew a full bar and no low
  // tone until a mode toggle forced a re-render. A bar that reports full at
  // 29% is worse than no bar.
  // A pool the server and this tab disagree about. The value splits into two
  // tappable halves - yours and theirs - and the cell keeps its size, so
  // nothing else on the sheet moves and nothing else is blocked: the other
  // pools, the rolls and the rest of the sheet all still work while this
  // sits here waiting to be answered.
  //
  // Both numbers are shown rather than one plus an explanation, because the
  // question at the table is which number is right, and that is answered by
  // seeing both.
  function conflictMarkup(key, c) {
    const half = (side, v, who) =>
      `<button type="button" class="cf-half" aria-label="${who}: ${v}"`
      + ` onclick="resolveConflict('${key}', '${side}')">`
      + `<span class="who">${who}</span>${v}</button>`;
    return half('mine', c.mine, 'yours')
      + '<i class="cf-rule"></i>'
      + half('theirs', c.theirs, 'theirs');
  }

  function paintPool(key, data, conflicts) {
    if (!data) return;
    const cur = data[key + '_current'], max = data[key + '_max'];
    const el = document.getElementById('play-cur-' + key);
    if (el) el.textContent = cur ?? '—';
    const card = el && el.closest('.vital');
    if (!card) return;

    // A conflict replaces the number with the choice, and clearing it puts
    // the number back - so this is the one place that owns .val's contents.
    const c = conflicts && conflicts[key];
    card.classList.toggle('conflict', !!c);
    const val = card.querySelector('.val');
    if (val) {
      const holder = val.querySelector('.cf');
      if (c) {
        const d = holder || document.createElement('span');
        d.className = 'cf';
        d.innerHTML = conflictMarkup(key, c);
        if (!holder) val.appendChild(d);
      } else if (holder) {
        holder.remove();
      }
    }
    const pct = fraction(cur, max);
    const bar = card.querySelector('.bar > i');
    if (bar) bar.style.width = Math.round(pct * 100) + '%';
    card.classList.toggle('low', max > 0 && cur != null && pct <= POOL_LOW);
    const inp = card.querySelector('input');
    if (inp) inp.value = cur ?? '';
  }

  // data-box is the box's own name, so a rule can reach one box without
  // relying on its position. The journal's reading measure is capped that way.
  // Derived from the title rather than passed, because a box whose title and
  // hook disagree is a bug waiting to happen.
  const boxSlug = (title) => String(title)
    .replace(/<[^>]*>/g, '')          // some titles carry tags - the name box has two
    .replace(/&amp;/g, ' ')
    .toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');

  // THE COLUMN ASSIGNMENT, IN ONE PLACE. data-col places a box in the
  // three-column body; WITHOUT IT A BOX FLOWS IN DOM ORDER, which is tab
  // order, and tab order is not lookup order - see the .sheet-3 comment in
  // styles.css.
  //
  // The split is by how often you look a thing up rather than by topic:
  //   a  numbers read constantly, in a narrow fixed column
  //   b  the long lists you scan, in the column that takes the slack
  //   c  what you read a paragraph of, capped to a reading measure
  //
  // A box with no entry gets no column and flows, which is correct for the
  // name header - it sits outside .sheet-3 entirely. The smoke test pins that
  // every box INSIDE the body has one, so a new box cannot silently land
  // anywhere.
  const BOX_COL = {
    attributes: 'a', vitals: 'a', experience: 'a', 'saving-throws': 'a', combat: 'a',
    resources: 'a', stage: 'a',
    'class-skills': 'b', 'related-skills': 'b', 'secondary-skills': 'b',
    granted: 'b', armor: 'b', equipment: 'b',
    'psionics-magic': 'c', background: 'c', bearing: 'c', notes: 'c', journal: 'c',
    'session-log': 'c',
  };

  // ─── THE THREE COLUMN STACKS ───
  // A grid gives you columns. It does not give you column STACKS, and the
  // difference is the whole of this function.
  //
  // Every box in a grid ROW is as tall as the tallest box in that row.
  // Attributes is six lines; it shared a row with Psionics & Magic and held
  // 500px of nothing underneath until the row could end and Experience could
  // start. No value reaches that space - it is a row track, not a gap, and
  // `gap`, `align-items` and `grid-auto-flow: row dense` are all answers to
  // different questions. (Dense backfills empty CELLS within a row. There is
  // no vertical backfill in grid at all.)
  //
  // Masonry is the direct answer and no shipping browser has it: checked in
  // Chrome 148, neither `grid-template-rows: masonry` nor the `item-pack`
  // spelling the spec is currently arguing about. So the boxes are moved into
  // three real stacks and the grid is left holding three items instead of
  // twenty. A stack has no rows to align: a short box is followed by the next
  // box, 14px down, at every height of neighbour.
  //
  // THE TABS SURVIVE THIS. A panel is SPLIT rather than dissolved - a panel
  // with boxes in two columns becomes two <section>s carrying the same
  // data-tab - so pickTab's querySelectorAll('.tabpanel') still toggles all
  // the pieces of a tab together, and the phone breakpoint and the print
  // block still act on the nodes they always did.
  //
  // Column ORDER is preserved exactly: panels are walked in DOM order and each
  // column keeps the order its boxes already had. What moves is where a column
  // starts, not what is in it.
  //
  // Runs on markup that has just been written by render(), so it is idempotent
  // by construction rather than by a guard.
  const SHEET_COLS = ['a', 'b', 'c'];

  // What the pass moves: the OUTERMOST elements carrying data-col. It stops
  // descending at one, so #granted-block travels as a unit and the boxes
  // refreshGranted() later writes into it stay in the column it is already in.
  //
  // An element with no data-col and nothing placed inside it is a STRAY, and
  // it is collected rather than skipped, because the panel it came from is
  // removed at the end of the pass - anything left behind would leave the page
  // silently. The Stage box was in exactly that state before this: built by
  // hand rather than through box(), with no column, landing wherever the grid
  // had room. It has one now, and this catches the next one.
  function placeable(root) {
    const out = [];
    const walk = (node) => {
      for (const el of node.children) {
        if (el.hasAttribute('data-col')) { out.push(el); continue; }
        const before = out.length;
        walk(el);
        if (out.length === before) out.push(el);
      }
    };
    walk(root);
    return out;
  }

  function stackColumns(body) {
    if (!body) return;
    const cols = new Map(SHEET_COLS.map((c) => {
      const el = document.createElement('div');
      el.className = 'sheet-col';
      el.dataset.col = c;
      return [c, el];
    }));

    for (const panel of [...body.children]) {
      if (!panel.classList.contains('tabpanel')) continue;
      // cloneNode(false) copies the tag, the classes - .on included - and
      // data-tab, and nothing else. That is the entire contract pickTab needs.
      const slices = new Map();
      for (const item of placeable(panel)) {
        let col = item.dataset.col;
        if (!cols.has(col)) {
          console.warn('sheet: no column for', item, '\u2014 filed under b');
          col = 'b';
        }
        let slice = slices.get(col);
        if (!slice) {
          slice = panel.cloneNode(false);
          cols.get(col).appendChild(slice);
          slices.set(col, slice);
        }
        slice.appendChild(item);
      }
      panel.remove();
    }

    for (const c of SHEET_COLS) body.appendChild(cols.get(c));
  }

  const box = (title, body, extra = '') => {
    const slug = boxSlug(title);
    const col = BOX_COL[slug];
    return `<div class="box" data-box="${slug}"${col ? ` data-col="${col}"` : ''}>` +
      `<div class="box-title"><span>${title}</span>${extra}</div><div class="box-body">${body}</div></div>`;
  };

  // What a class hands out that is not a pool, a skill or a power - doses,
  // charges, uses per day. Declared in the class's own frontmatter under
  // trackable_resources; see the class-import skill's frontmatter reference.
  //
  // NOTHING IS INVENTED HERE. A class that declares none gets no box, which
  // is every class in the catalogue today: the mechanics are famous enough
  // to fill in from memory and that is exactly the failure the book-ingest
  // rules exist to stop. `uppers` is the stock Juicer example and appears in
  // none of the twelve imported Juicers' text.
  //
  // max_formula is shown as written. It is not evaluated HERE and never will
  // be: resolving one needs the character's attributes, and this file reads no
  // character state. sheet.js resolves what it can before calling this and
  // hands over rows whose `max` is already a number, so a resolved resource
  // arrives looking exactly like one that declared `max: 3` outright.
  //
  // What still arrives as a formula is anything with a die in it. That is not
  // an oversight - a resource has nowhere to store a roll, so evaluating it
  // per render would move the character's capacity every time the page
  // painted. See fixedFormulaValue in dice.js.
  const trackableRows = (list) => (Array.isArray(list) ? list : [])
    .filter((r) => r && (r.label || r.key))
    .map((r) => {
      const cap = r.max != null ? String(r.max)
        : (r.max_formula ? String(r.max_formula) : '\u2014');
      const reset = r.reset_on && r.reset_on !== 'never'
        ? `<span class="muted small">per ${escHtml(String(r.reset_on))}</span>` : '';
      return `<div class="field">
        <span class="lbl">${escHtml(String(r.label || r.key))}</span>
        <span class="dots"></span>
        <span class="val">${escHtml(cap)}</span>
      </div>${reset || r.note ? `<div class="muted small" style="margin:-2px 0 6px">
        ${reset}${reset && r.note ? ' \u00b7 ' : ''}${r.note ? escHtml(String(r.note)) : ''}
      </div>` : ''}`;
    }).join('');

  const field = (label, value, dim) =>
    `<div class="field"><span class="lbl">${label}</span><span class="dots"></span>` +
    `<span class="val${dim ? ' dim' : ''}">${value}</span></div>`;

  global.sheetLayout = {
    POOL_TONES, POOL_LOW, poolCard, paintPool, boxSlug, BOX_COL, box, field,
    trackableRows, stackColumns,
  };
})(globalThis);
