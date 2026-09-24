// The markup the app actually renders: the sheet's column stacks and pool
// widgets, the wizard rail, the GM dashboard, the print stylesheet, play mode,
// the session log and the two-people-one-character path.
//
// These read sheet.js, sheet.html, app.js, index.html, dashboard.js and
// styles.css as TEXT and assert against it, because the render path is
// browser-only and the test cannot execute it. That is the shared property
// that makes them one file - not the feature they cover.
//
// A text check is weaker than running the thing, and the compensation is that
// each one names the symptom it was written for. Keep that: a regex with no
// story is unmaintainable the day it fails.
//
// Split out of smoke.mjs unchanged.

import { existsSync, readFileSync } from 'node:fs';
import { join } from 'node:path';

import { appDir, repoRoot, check, section, wantSection, appPath } from '../harness.mjs';
import { fixedFormulaValue } from '../../js/dice.js';
import { parseClassMarkdown } from '../../js/parser.js';
import { buildProposal } from '../../js/leveling.js';

// Every @media print block's body, brace-matched and concatenated.
//
// This replaces `css.slice(css.lastIndexOf('@media print'))`, which assumed the
// LAST print block was the sheet's. styles.css has seven of them, and appending
// an eighth for the codex retargeted eighteen assertions at it — all eighteen
// failed at once, which was at least loud. The quiet version of that failure is
// worse: a rule that happens to match in the wrong block reads as a pass. The
// slice also swept up the ordinary screen CSS sitting between two print blocks,
// so a screen rule could satisfy a print assertion.
function printCss(css) {
  const out = [];
  let i = 0;
  while ((i = css.indexOf('@media print', i)) !== -1) {
    const open = css.indexOf('{', i);
    if (open === -1) break;
    let depth = 0;
    let j = open;
    for (; j < css.length; j++) {
      if (css[j] === '{') depth++;
      else if (css[j] === '}' && --depth === 0) break;
    }
    out.push(css.slice(open + 1, j));
    i = j + 1;
  }
  return out.join('\n');
}

// Cut one function's body out of a source file, on either line ending.
//
// REPO-AUDIT.md G8, and this is what the first CI run on Linux found. Three
// places here sliced a function body by searching for a HARDCODED CRLF -
// `'\r\n}'`, or `String.fromCharCode(13, 10)`. On a LF checkout every one of
// those `indexOf` calls returns -1, and `slice(start, -1)` does not fail: it
// silently returns the whole rest of the file.
//
// That went two ways, and the quiet one is the reason this helper exists rather
// than three small edits:
//
//   * `togglePlay` FAILED loudly - the rest of the file contains `render()`,
//     which is exactly what that check forbids.
//   * `paintPool` PASSED VACUOUSLY. Its `painter` became the rest of the file,
//     so the `src.replace(painter, '')` below it deleted nearly everything and
//     the "no pool write bypasses it" check then searched a handful of lines
//     and found nothing wrong. Green, and testing almost none of the file.
//
// So this returns null when it cannot find both ends, and every caller asserts
// that before using the body. A missing delimiter is now a named failure
// instead of either a confusing one or a silent pass.
//
// The column-0 `}` assumption is the original's and is kept: a function body
// indents its inner braces, so the first line-initial `}` after the signature
// is the function's own.
function functionBody(src, signature) {
  const from = src.indexOf(signature);
  if (from === -1) return null;
  const rest = src.slice(from);
  const end = rest.search(/\r?\n\}/);
  return end === -1 ? null : rest.slice(0, end);
}

// Declared so a --section run can skip the module without reading it.
const SECTIONS = [
  'Perception',
  'The sheet shows every derived combat row',
  'One pool widget, both modes',
  'The sheet body, three column stacks',
  'Presentation is a separate file',
  'A power spends the pool its button says it spends',
  'A permanent P.P.E. spend lowers the maximum wherever it is shown',
  'A Talent earned at level-up can be chosen, then or later',
  'The wizard rail',
  'Undo instead of confirm for one-row deletes',
  'The GM dashboard',
  'The printed sheet',
  'Play mode is a mode, not a layout',
  'Trackable resources',
  'The session log',
  'Two people, one character',
  'Board & Tissue: the chip column and the mark',
  'The front door agrees with the rooms',
  'Changes that could not be sent',
  'The sheet reads only item fields its endpoint sends',
  'The codex',
  'One header for five apps',
  'Present mode shows without revealing',
  'Statted NPCs: one panel, two pages',
  'The name panel beside every Name box',
];

export function run() {
  if (!SECTIONS.some(wantSection)) return;

  // ---------- Perception is a roll RUE grants and the sheet had nowhere to put ----------
  // RUE gives Perception its own section (printed p367): D20 plus whatever the
  // O.C.C./R.C.C. grants, against 4 / 8 / 14 / 17 by difficulty. The book hands
  // out fifty such bonuses, and twelve catalog classes already mentioned one - as
  // prose, because no key existed. The Dog Boy's own file said it outright:
  // "+5 Perception, +2 disarm and +2 vs disease have no bonus key".
  section('Perception');
  {
    const win = {};
    new Function('globalThis', readFileSync(join(appDir, 'js', 'derive.js'), 'utf8')).call(win, win);

    const plain = win.derive.combat({ PP: 16, PS: 16, Spd: 12 });
    check('a character with no class bonus has Perception 0', plain.perception === 0);
    check('and Perception is present rather than undefined, so a bonus has a base',
      'perception' in plain);

    const boosted = win.derive.combat({ PP: 16, PS: 16, Spd: 12 }, undefined,
      { combat: { perception: 5 } });
    check('a class bonus lands on it', boosted.perception === 5);
    check('and does not disturb the attribute-derived rows',
      boosted.strike === plain.strike && boosted.parry === plain.parry);

    // No attribute feeds Perception - RUE gives the bonus to the class, not to a
    // score - so P.P. must not leak into it the way it does for strike/parry.
    const highPP = win.derive.combat({ PP: 24, PS: 16, Spd: 12 });
    check('no attribute feeds Perception', highPP.perception === 0);
    check('even though the same call derives a higher strike from P.P.',
      highPP.strike > plain.strike);
  }

  // Every row derive.combat() produces needs somewhere to appear, or a class can
  // grant a bonus that lands in the data and never reaches the player. That is
  // exactly how Perception went missing.
  section('The sheet shows every derived combat row');
  {
    const win = {};
    new Function('globalThis', readFileSync(join(appDir, 'js', 'derive.js'), 'utf8')).call(win, win);
    const derived = Object.keys(win.derive.combat({ PP: 12, PS: 12, Spd: 12 }));
    const sheet = readFileSync(appPath('sheet.js'), 'utf8');
    const block2 = sheet.slice(sheet.indexOf('const COMBAT_FIELDS'),
      sheet.indexOf('];', sheet.indexOf('const COMBAT_FIELDS')));
    const shown = [...block2.matchAll(/\['([a-z_]+)',/g)].map((m) => m[1]);
    const missing = derived.filter((k) => !shown.includes(k));
    check('every derived combat row has a labelled field on the sheet',
      missing.length === 0, missing.join(', '));

    // The same contract for saves - and this is the list that actually drifted.
    // sheet.js says so directly above SAVE_FIELDS: it "was not a shorter view
    // chosen on purpose - it was the first list before three keys were added to
    // derive.js and only one copy was updated". The combat check existed and this
    // one did not, so the guarded side was the side that never broke, and the
    // side with a recorded incident was unguarded (SKILL-AUDIT F22).
    //
    // `psionics_target` is excluded deliberately: the sheet renders it ABOVE the
    // sixteen as its own editField, because it is the number you roll against
    // rather than a bonus - the only absolute value in that box.
    const savesDerived = Object.keys(win.derive.saves({ ME: 12, PE: 12, PP: 12 }))
      .filter((k) => k !== 'psionics_target');
    const savesBlock = sheet.slice(sheet.indexOf('const SAVE_FIELDS'),
      sheet.indexOf('];', sheet.indexOf('const SAVE_FIELDS')));
    const savesShown = [...savesBlock.matchAll(/\['([a-z_]+)',/g)].map((m) => m[1]);
    const savesMissing = savesDerived.filter((k) => !savesShown.includes(k));
    check('every derived save row has a labelled field on the sheet',
      savesMissing.length === 0,
      `${savesMissing.join(', ')} - add it to SAVE_FIELDS in sheet.js, or the bonus lands in the data and never reaches the player`);
  }

  // ---------- One pool widget, both modes ----------
  // The sheet and play mode used to draw pools from two separate code paths:
  // .vital with an input, and .play-pool with its own +/- buttons, at two sizes.
  // They are one component now, and these checks pin the parts of that contract
  // that fail SILENTLY - each of them is something no other test in this file
  // would notice.
  //
  // The load-bearing one is the value being two nodes. Seven mutation paths
  // write a pool by id with .textContent - adjustPool, take-damage and its
  // rollback, undo, rest and its rollback, and spending a power. .textContent
  // does nothing to an <input>, so if the widget ever collapses to a single
  // input every one of those becomes a no-op: the number sits still while the
  // data underneath changes correctly, and the sheet still saves the right
  // value. Nothing on screen says anything is wrong.
  section('One pool widget, both modes');
  {
    // The sheet's presentation lives in js/sheet-layout.js and its data logic
    // in sheet.js. This contract spans both, so both are read.
    const src = readFileSync(appPath('sheet.js'), 'utf8')
      + readFileSync(join(appDir, 'js', 'sheet-layout.js'), 'utf8');
    const css = readFileSync(join(appDir, 'styles.css'), 'utf8');

    check('there is a single pool component',
      /function poolCard\(/.test(src), 'poolCard() is gone');

    // This used to read `callers >= 3` - the definition plus TWO render paths,
    // which was the phase-3 property. There is one render path now, so the
    // stronger statement is exactly one caller, and an extra one means a second
    // path has grown back.
    const callers = [...src.matchAll(/poolCard\(/g)].length;
    check('the one render path is its only caller', callers === 2,
      `poolCard appears ${callers} times; expected its definition plus ONE caller`);
    // WHAT THIS PINS IS THE LAST TWO ARGUMENTS - `w, true`, the steppers - and not
    // the shape of the ones before them. It used to match the whole call
    // literally, `c[key + '_max']` included, so it failed the day the maximum
    // started coming from `poolMax(c, key)` (migration 065, BOOK-INGEST-AUDIT
    // F101) - a change to where the number comes from, which is not what this
    // check is about. The message below was always the real subject.
    check('and it is asked for steppers, which CSS then gates',
      /poolCard\(key, label,[\s\S]*?, w, true\)/.test(src),
      'the sheet no longer renders the steppers play mode reveals');

    const poolCardBody = functionBody(src, 'function poolCard(');
    check('poolCard()\'s body can be located', poolCardBody !== null,
      'no line-initial closing brace after the signature - the checks below would read the whole file');
    const body = poolCardBody ?? '';

    check('the widget renders the input the sheet saves through',
      body.includes('id="stat-${key}"'), 'saveSheet() reads $(\'stat-\' + key)');
    check('and the <b> the seven mutation paths write to',
      body.includes('id="play-cur-${key}"'),
      'adjustPool, damage, undo, rest and power spend all target play-cur-<key>');

    // Both nodes, in one element. A widget carrying only one of them would pass
    // the two checks above if the ids were merely present somewhere in the file.
    check('both live in the same .val, so neither can drift out of the widget',
      /class="val">[^\n]*id="stat-\$\{key\}"[^\n]*id="play-cur-\$\{key\}"/.test(body),
      'the input and the <b> are no longer siblings in .val');

    // Every path that changes a pool paints through ONE function. Writing the
    // number by hand was enough while the widget was only a number; it now
    // carries a bar and a low tone, and a half-update leaves the bar at its
    // render-time width - H.P. at 4 of 14 drew a full bar until a mode toggle
    // forced a re-render. Play mode never re-renders, so that bar stayed wrong
    // for the whole session.
    check('there is one function that paints a pool',
      /function paintPool\(/.test(src), 'paintPool() is gone');
    const painters = [...src.matchAll(/paintPool\(/g)].length;
    check('and all seven mutation paths go through it', painters >= 8,
      `found ${painters}; expected its definition plus seven call sites`);
    // The guard matters most here. When this slice silently became the rest of
    // the file, `src.replace(painter, '')` below deleted nearly all of it and
    // the bypass check passed while reading almost nothing.
    const paintPoolBody = functionBody(src, 'function paintPool(');
    check('paintPool()\'s body can be located', paintPoolBody !== null,
      'no line-initial closing brace after the signature - the bypass check below would read almost nothing');
    const painter = paintPoolBody ?? '';
    check('it repaints the bar, not just the number',
      painter.includes("querySelector('.bar > i')"), 'paintPool leaves the bar stale');
    check('and the low tone',
      /classList\.toggle\('low'/.test(painter), 'paintPool leaves the low class stale');
    // paintPool itself is the one legitimate writer, so it is cut out before
    // asking whether anything else still sets the number by hand.
    const elsewhere = src.replace(painter, '');
    check('no pool write bypasses it',
      !elsewhere.includes("$('play-cur-'"),
      'a mutation path still reaches for the pool node directly');

    check('the retired widget is gone from the markup',
      !/class="play-pool"|pp-val|pp-label|pp-btns/.test(src),
      'something still emits .play-pool');
    check('and from the stylesheet',
      !/^\.play-pool[\s.{]/m.test(css), 'styles.css still styles .play-pool');

    // Print hides every input outright, so the <b> is the only thing that can
    // carry a pool value onto paper. This rule is the whole reason the printed
    // sheet still has numbers in it.
    check('print reveals the <b>, or every pool prints blank',
      /\.vital \.val b \{ display: inline !important; \}/.test(css),
      'the print block no longer un-hides the pool value');
    check('and hides the bar and steppers, which are screen affordances',
      /\.vital \.bar, \.vital \.steppers \{ display: none !important; \}/.test(css),
      'print still draws the bar or the steppers');

    // Mode is decided in CSS, not by rendering two different widgets.
    check('sheet mode shows the input and hides the <b>',
      /\.vital \.val b \{ display: none; \}/.test(css), 'the <b> is not hidden by default');
    check('play mode swaps them',
      /body\.play-mode \.vital \.val input \{ display: none; \}/.test(css)
      && /body\.play-mode \.vital \.val b \{ display: inline; \}/.test(css),
      'body.play-mode no longer swaps the two value nodes');
    check('and steppers are gated on play mode in CSS, not just on a flag',
      /\.vital \.steppers \{ display: none; \}/.test(css)
      && /body\.play-mode \.vital \.steppers \{/.test(css),
      'a sheet-mode render could leak steppers');

    // Every pool has a tone, or --tone falls back and the bar goes grey.
    const tones = src.slice(src.indexOf('const POOL_TONES'), src.indexOf('};', src.indexOf('const POOL_TONES')));
    const pools = src.slice(src.indexOf('const POOLS ='), src.indexOf('];', src.indexOf('const POOLS =')));
    const poolKeys = [...pools.matchAll(/\['([a-z]+)',/g)].map((m) => m[1]);
    const missingTone = poolKeys.filter((k) => !new RegExp(`\\b${k}:`).test(tones));
    check('every pool in POOLS has a tone', missingTone.length === 0,
      `no --tone for: ${missingTone.join(', ')}`);
    check('and every tone is a token, not a hex',
      !/#[0-9a-fA-F]{3,8}/.test(tones), 'a pool tone hardcodes a colour');
  }

  // ---------- The sheet body, three column stacks ----------
  // The sheet used to show one tab at a time on a 1440 desktop, the same as on a
  // 390 phone, inside a 900px container sized for prose. It is now a three-column
  // body in its own container, with tabs demoted to a phone affordance.
  //
  // These checks pin the parts that fail SILENTLY. The loudest is the column
  // assignment: display: contents does not change the DOM tree, so a box left
  // unplaced does not error - it lands in whatever column has room, three columns
  // from the thing it belongs to. That is how the skills filter first rendered
  // above Psionics.
  section('The sheet body, three column stacks');
  {
    // The sheet's presentation lives in js/sheet-layout.js and its data logic
    // in sheet.js. This contract spans both, so both are read.
    const src = readFileSync(appPath('sheet.js'), 'utf8')
      + readFileSync(join(appDir, 'js', 'sheet-layout.js'), 'utf8');
    const css = readFileSync(join(appDir, 'styles.css'), 'utf8');
    const html = readFileSync(appPath('sheet.html'), 'utf8');

    check('the sheet has its own container',
      /\.wrap\.wrap-sheet \{ max-width: 1640px; \}/.test(css), 'wrap-sheet is gone');
    check('and sheet.html asks for it',
      /<main class="wrap wrap-sheet">/.test(html), 'sheet.html is back on the prose container');

    // N2's escape hatch existed only because .wrap was 900px.
    check('the skills escape hatch is gone with the container that caused it',
      !/\.tabpanel\[data-tab="skills"\] \{/.test(css), 'the width + translate hack is still here');

    // Tabs: a phone affordance, not the desktop default.
    check('panels dissolve by default',
      /^\.tabpanel \{ display: contents; \}/m.test(css), 'tabpanel is not display: contents');
    check('the tab bar is hidden by default',
      /^\.tabbar \{ display: none; \}/m.test(css), 'the tab bar still shows on desktop');
    // A PHONE **OR ANY TOUCH SCREEN**, which is not the same as a narrow one.
    // An iPad Pro 13" is 1032px in portrait and 1376 in landscape, so the width
    // test alone handed the tablet these tabs were built for the desktop body:
    // 5,908px of scroll in portrait, against 1,225px on an 820px iPad Air
    // showing the same character.
    //
    // Anchored INSIDE the block with \s*, rather than spanning to it with
    // [\s\S]*?. The regex this replaces did span, and when the condition
    // changed it kept passing — by starting at an unrelated `.imp-row` media
    // query 600 lines earlier and finding these rules outside any 820-only
    // block at all. It was green and testing nothing.
    check('and both come back on a phone, or on any touch screen at any width',
      /@media \(max-width: 820px\), \(pointer: coarse\) \{\s*\.tabbar \{ display: flex; \}\s*\.tabpanel \{ display: none; \}/.test(css),
      'the tabs no longer return below 820px or on a touch device');
    check('and the body agrees with the tab bar about which layout is on',
      /@media \(max-width: 820px\), \(pointer: coarse\) \{\s*\.sheet-grid\.sheet-3 \{ grid-template-columns: 1fr; \}/.test(css),
      'the conditions have drifted: a tab bar over already-visible panels, or hidden panels with nothing to press');
    check('and a wide touch screen caps the single column',
      /@media \(pointer: coarse\) and \(min-width: 900px\) \{\s*\.sheet-grid\.sheet-3 \{ max-width: 900px;/.test(css),
      'an iPad in landscape drags a skills table across 1376px');

    // ── THE THIRD MODE: THE STRIP AS NAVIGATION (P5a, 2026-09-20) ──
    //
    // The two checks above are the two states this page had. A mouse on a wide
    // screen got the second one and no way to reach a section: 3,687px at
    // 1440x900 with a level-12 character, 4.1 screens, and THREE headings in
    // the whole document. The answer is not to hide panels on a laptop - the
    // check above still pins that it does not - so the strip is shown OVER the
    // already-visible panels and pressing one scrolls.
    check('the strip can be navigation instead of tabs',
      /^\.tabbar\.tabbar-sections \{ display: flex; \}/m.test(css),
      'the third mode is gone, so a laptop has no way to reach a section');
    // The class is what distinguishes the two visible states, so a bar over
    // visible panels can never be an accident of a media query.
    check('and only that class shows a bar over visible panels',
      /nav\.classList\.toggle\('tabbar-sections', !tabs\)/.test(src),
      'nothing adds the class, or something else does');

    // ONE CONDITION, THREE COPIES, AND THEY MUST BE ONE STRING. The stylesheet
    // warns that the bar and the panels disagreeing about which layout is on is
    // the failure here; sheet.js now carries a copy of the same query to decide
    // which of the two the strip is. Pinned rather than trusted.
    const TAB_MODE = '(max-width: 820px), (pointer: coarse)';
    const cssCopies = (css.match(/@media \(max-width: 820px\), \(pointer: coarse\)/g) || []).length;
    check('every copy of the tab-mode condition is the same string',
      cssCopies >= 2 && src.includes(`const TAB_MODE = '${TAB_MODE}'`),
      `${cssCopies} in the stylesheet, and sheet.js must hold the identical string`);
    check('and sheet.js decides the mode from it rather than from a width',
      /const tabModeMq = window\.matchMedia\(TAB_MODE\)/.test(src)
      && !/innerWidth\s*[<>]=?\s*820/.test(src),
      'a second, hand-rolled idea of where the breakpoint is');

    // THE TARGET IS A BOX, NEVER THE SLICE. `.tabpanel` is display: contents in
    // this mode, so it generates NO BOX: scrollIntoView does nothing, a
    // scroll-margin on it applies to nothing, and its rect is 0,0,0,0. Built
    // that way first and measured: every press "scrolled" to 0 and left the
    // section 486px behind the sticky header.
    check('a section scrolls to its first box, not to the slice',
      /\.tabpanel\[data-tab="\$\{tab\}"\] > \.box/.test(src)
      && /const target = sectionTarget\(tab\)/.test(src),
      'the scroll target is the display: contents element again');
    check('and the scroll offset is on .box for the same reason',
      /^\.box \{ scroll-margin-top: calc\(var\(--header-h, 0px\) \+ var\(--sticky-h, 0px\)/m.test(css)
      && !/^\.tabpanel \{ scroll-margin-top/m.test(css),
      'scroll-margin sits on an element that generates no box');
    // The strip lives inside the sticky block, so showing it makes that block
    // taller than the height sizeSticky already published. Measured: 185px
    // recorded against a real bottom of 345, and every press landed 57px behind
    // the header.
    check('and the sticky height is re-measured after the strip appears',
      /sticky\.sizeSticky\(\);\s*\}/.test(src.slice(src.indexOf('function syncStripMode'))),
      'syncStripMode shows the bar and leaves --sticky-h stale');

    // A control that scrolls must not claim to be a tab: role="tab" promises a
    // panel swap, and aria-selected on it is a lie about state.
    check('the strip drops its tab roles when it is a nav',
      /el\.removeAttribute\('role'\);\s*el\.removeAttribute\('aria-selected'\);/.test(src),
      'the buttons still say role="tab" while they scroll');

    // THE OUTLINE. Three headings on a four-screen document, and the fix is not
    // a heading per panel: stackColumns files an element with no data-col as a
    // stray, so an <h2> added to a panel lands in column b with a console
    // warning. Measured: 7 panels became 10 and the page grew 568px. The box is
    // the section here, and it already had a title.
    const layout = readFileSync(join(appDir, 'js', 'sheet-layout.js'), 'utf8');
    check('every box title is a real heading',
      /<div class="box-title"><h2>\$\{title\}<\/h2>\$\{extra\}<\/div>/.test(layout),
      'the box title is a span again and the sheet has no outline');
    check('and the heading wraps the title alone, never the buttons',
      !/<h2>\$\{title\}\$\{extra\}/.test(layout),
      'the extra controls are inside the heading');
    check('and it is styled to change nothing on screen',
      /^\.box > \.box-title > h2 \{ margin: 0; font: inherit;/m.test(css),
      'the h2 brings its own size or margin');

    // ── PLAY MODE SUBTRACTS THE EDITING TOO (P5b, 2026-09-20) ──
    //
    // It already hid four record-keeping boxes, so "play mode only adds" was
    // never true - what it never subtracted is the editing inside the boxes it
    // KEEPS. On the Gear tab that was most of the screen: a quantity input, an
    // equipped checkbox, a remove button and an enchantment link on all 23
    // rows, then a six-field add form. Measured at 1350px on a level-12
    // character: the Equipment box is 2,803px on the sheet and 1,146px in play,
    // a row 111.6px against 44.9px, and 95 upkeep controls against none.
    check('play mode hides the controls that belong between sessions',
      /^body\.play-mode \.upkeep \{ display: none; \}/m.test(css),
      'the upkeep hook is gone and play mode shows the whole editor again');
    // THE BOX STAYS. Gear is "lookup a player does mid-session" per the rule
    // that hides the other four, and that is still true - what you carry is
    // exactly what you check mid-fight. Only the editing goes.
    check('and does NOT hide the boxes themselves',
      !/body\.play-mode \.box\[data-box="equipment"\]/.test(css)
      && !/body\.play-mode \.box\[data-box="armor"\]/.test(css),
      'play mode now hides gear or armor outright, which is not what was agreed');
    // A hidden input must never mean a hidden number. Same pairing as the pool
    // widget, and the gear row's mirror already existed for paper.
    check('a hidden control leaves its value on screen',
      /^\.read-value \{ display: none; \}/m.test(css)
      && /^body\.play-mode \.read-value \{ display: inline; \}/m.test(css),
      'the value mirror is gone, so play mode hides the quantity itself');
    check('and paper still gets that value too',
      /\.read-value \{ display: inline; \}/.test(printCss(css)),
      'the print block hides every input and no mirror replaces it');
    const rowSrc = functionBody(src, 'function inventoryRowsHtml()');
    check('inventoryRowsHtml is readable', !!rowSrc);
    const marked = (rowSrc || '').match(/class="upkeep"|btn-ghost upkeep/g) || [];
    check('the quantity, the equipped box and the remove button are all marked',
      marked.length >= 3, `${marked.length} marked — a gear row still leaves an editing control at the table`);
    // Armour takes damage at the table, so its stats stay editable and only the
    // destructive control is upkeep. Checked because the obvious sweep would
    // have marked the whole box.
    check('but armour keeps the stats a hit changes',
      /data-armor-remove="\$\{i\}"/.test(src.slice(src.indexOf('function armorSlotHtml')))
      && !/data-key="mdc_current"[^>]*upkeep/.test(src),
      'the armour stats went with the remove button');
    check('and the player is told where the editing went',
      /class="muted small play-only"/.test(src)
      && /^body\.play-mode \.play-only \{ display: block; \}/m.test(css),
      'the editor vanishes with nothing saying how to get it back');

    // ── HIERARCHY: SPEND THE RANK data-col ALREADY CARRIES (P5c, 2026-09-20) ──
    //
    // BOX_COL has ranked every box since the column stacks shipped - `a` read
    // constantly, `b` scanned, `c` read a paragraph of - and spent all of it on
    // grid-column. Three ranks, one appearance.
    check('the three columns read as three ranks',
      /^\.box\[data-col="a"\] > \.box-title \{ color: var\(--text-primary\); \}/m.test(css)
      && /^\.box\[data-col="c"\] > \.box-title \{ color: var\(--text-muted\); \}/m.test(css),
      'the rank is back to being placement only');
    // Contrast on --bg-secondary, which is what a box title sits on:
    // --text-primary 14.18, --text-secondary 6.58, --text-muted 5.45. A 10px
    // 800-weight label is SMALL text and needs 4.5:1, so the quiet end keeps
    // 21% of headroom. The quiet end is the one to watch if this is ever
    // pushed further.
    check('and the quiet end still clears 4.5:1',
      !/\.box\[data-col="c"\] > \.box-title \{ color: var\(--text-(secondary|primary)\)/.test(css),
      'the ranks collapsed rather than separated');
    // This file reserves --accent for what you can act on and says so twice.
    // A heading is not clickable, so the rank may not be spent on colour.
    check('and no rank is spent on the accent',
      !/\.box\[data-col="[ac]"\] > \.box-title \{ color: var\(--accent/.test(css),
      'a section label took the colour the Use button needs');
    check('prose gets a reading size to go with its measure',
      /^\.box\[data-col="c"\] \.box-body \{ font-size: 14px;/m.test(css),
      'three paragraphs of background still render at a skill table size');

    // THE DOCUMENT'S SUBJECT. The name went through box() like every other
    // title, so it rendered at 10px uppercase tracked to 0.18em - the same
    // treatment as "Bearing" - while the page's <h1> is the app's name.
    check('the character name is the identity box, hooked by a class',
      /const box = \(title, body, extra = '', cls = ''\)/.test(layout)
      && /class="box\$\{cls \? ' ' \+ cls : ''\}"/.test(layout)
      && /`, '', 'identity'\)\}/.test(src),
      'the name box has no stable hook again - data-box is derived from the title');
    check('and the name is a name rather than a label',
      /^\.box\.identity > \.box-title > h2 \{[\s\S]*?text-transform: none;/m.test(css)
      && /^\.box\.identity > \.box-title > h2 \{[\s\S]*?font-size: 26px;/m.test(css),
      'the character name is uppercase and 10px again');

    // PAPER IS NOT A SCREEN. Both of the above have to stop at the print block:
    // a 26px name on a 10pt sheet, and three ink weights where ink is ink.
    const printed = printCss(css);
    check('the name prints at a size paper can afford',
      /\.box\.identity > \.box-title > h2 \{ font-size: 13pt;/.test(printed),
      'the 26px name reaches paper');
    check('and the three ranks collapse to ink',
      /\.box\[data-col="a"\] > \.box-title,\s*\.box\[data-col="c"\] > \.box-title \{ color: #000; \}/.test(printed),
      'a printed label is grey because a screen needed a hierarchy');

    // ── 44px MEANS 44px (P5d, 2026-09-20) ──
    //
    // The play-mode header has claimed "44px tap targets" since play mode
    // shipped, and the .play-dice comment says "Same 44px target as the amount
    // buttons". Both rules said 40. Measured at 375x812 in play mode on a
    // level-12 character: 65 of 94 visible controls were under 44px in some
    // dimension - the claim held for the tab strip and the roll buttons, which
    // is where it was written, and nowhere else. After this: ZERO under 44 in
    // HEIGHT outside the shared header.
    const target44 = [
      ['the amount chips and Damage', /\.play-amt button \{\s*min-width: 44px; min-height: 44px;/],
      // The percentile lost its own row in P5e and now takes the amount
      // strip's size, which is the rule directly above. What it must not lose
      // is the 44px, so this asserts it is in that strip rather than styled
      // loose somewhere with its own number.
      ['the bare percentile', /#play-actions \.pct \{ color: var\(--text-secondary\); padding: 0 12px; \}/],
      ['any other amount', /\.play-amt-custom \{ width: 64px; min-height: 44px;/],
      ['where the hit lands', /\.play-hit-to \{ min-height: 44px;/],
      ['the melee reset glyph', /\.play-melee button\.ghost \{ color: var\(--text-secondary\); min-width: 44px; \}/],
      ['a power chip', /\.pw-chip \{\s*min-height: 44px;/],
      ['the weapon buttons', /\.play-melee button \{\s*min-height: 44px;/],
    ];
    for (const [what, re] of target44) {
      check(`${what} is a 44px target`, re.test(css), 'still 40px, against the claim two comments make');
    }
    // The two big groups, and they are play-mode only ON PURPOSE: 44px on 33
    // override inputs adds ~360px to the column that is already the longest
    // thing on the page, and the sheet is read with a pointer as often as a
    // thumb. Play mode is the mode that says it is for a table.
    check('the override inputs and small buttons grow for a thumb',
      /^body\.play-mode \.mini-in \{ min-height: 44px; \}/m.test(css)
      && /^body\.play-mode \.btn\.btn-sm \{ min-height: 44px; \}/m.test(css),
      'the 33 dashed override inputs are 33px tall again');
    check('and so does the name that opens an item',
      /^body\.play-mode \.power-toggle \{ min-height: 44px; display: inline-flex;/m.test(css),
      'the control that opens a spell is 17px tall again');
    check('but the SHEET keeps its density',
      !/^\.mini-in \{[^}]*min-height: 44px/m.test(css),
      'the 44px went global and the sheet grew by a column');

    // ── UI-AUDIT F58: the pool strip on paper (2026-09-20) ──
    //
    // Measured from the PDF's own content streams, not a screenshot: a
    // 720x51pt rect filled `0.039 0.059 0.055` - #0A0F0E, --bg-primary - with
    // the three cards on it at #1E2724. THE BAND WAS .sheet-sticky, not the
    // cards, which is why the parent is the rule that matters: whitening
    // .vital alone would have left three white holes punched in a black band.
    check('the sticky block does not print its screen ground',
      /\.sheet-sticky \{ background: #fff !important; \}/.test(printed),
      'the pool strip prints as a black band again');
    check('and neither do the pool cards',
      /\.vital \{\s*background: #fff !important;/.test(printed),
      'the three cards print dark on white paper');
    // The one thing here that ADDS to the page. `.vital { border-color: #999 }`
    // in the same block is later than the screen rule and equal in
    // specificity, so on paper which pool is which was carried by nothing.
    check('but the per-pool tone is re-asserted on paper',
      /\.vital \{[^}]*border-top-color: var\(--tone, #999\);/.test(printed),
      'the H.P./S.D.C./P.P.E. edges print grey and say nothing');
    // The labels were never the problem - they read as invisible against a
    // black ground. #333 on white is 12.6:1, and that rule governs two other
    // selectors, so F58's proposed #000 is deliberately NOT taken.
    check('and the shared label rule is left alone',
      /\.field > \.lbl, \.skill-head th, \.vital \.lbl \{ color: #333 !important; \}/.test(printed),
      'the label colour moved, taking .field and .skill-head with it');

    // ── UI-AUDIT F57 option A: shrink it before it is uploaded ──
    //
    // This platform cannot resize an image (docs/pages-to-workers-migration.md
    // row: Workers yes, Pages no), so the only place the bytes can be made
    // smaller is before they leave the browser.
    const down = readFileSync(join(appDir, 'js', 'downscale.js'), 'utf8');
    const gmHtml = readFileSync(join(repoRoot, 'apps', 'gm-tools', 'index.html'), 'utf8');
    // Matched as SCRIPT TAGS, not as bare filenames: the comment above the tag
    // names dashboard.js, and a plain indexOf found that first and reported the
    // order backwards. The same shape of mistake the appnav checks make.
    const tagAt = (f) => gmHtml.indexOf(`<script src="${f}"`);
    check('the downscaler is loaded before the page that uses it',
      tagAt('/apps/character-creator/js/downscale.js') > 0
      && tagAt('/apps/character-creator/js/downscale.js') < tagAt('dashboard.js'),
      'downscale.js is missing or loads after dashboard.js');
    // THE HEADER COMES FROM THE BLOB. The server reads that one header for the
    // R2 key's extension, the stored content_type AND the Content-Type it
    // serves later, so a re-encoded blob described by the original file's type
    // is wrong in three places at once. The finding's text omitted this.
    const dashSrc = readFileSync(appPath('dashboard.js'), 'utf8');
    const upload = functionBody(dashSrc, 'async function uploadPicture(');
    check('the upload describes what it actually sends',
      !!upload && /const body = await downscale\.toUpload\(file\);/.test(upload)
      && /'Content-Type': body\.type/.test(upload) && !/'Content-Type': file\.type/.test(upload),
      'the request still names the original file type');
    // GIF IS NEVER RE-ENCODED: canvas.toBlob cannot write image/gif, browsers
    // fall back to PNG, and an animated gif would be flattened to one frame.
    check('gif is left alone rather than flattened',
      /REENCODABLE = new Set\(\['image\/jpeg', 'image\/png', 'image\/webp'\]\)/.test(down),
      'gif can reach the canvas, and an animated one comes back as one frame');
    check('the type survives the round trip',
      /blobFrom\(canvas, file\.type\)/.test(down),
      'a PNG can come back as a JPEG, losing its transparency');
    // A small PNG re-encoded can come out BIGGER, which would push a picture
    // towards the 5MB cap rather than away from it.
    check('a re-encode that made things worse is discarded',
      /if \(!out \|\| out\.size >= file\.size\) return file;/.test(down),
      'a bigger blob can be uploaded in place of the original');
    check('and nothing here can block an upload',
      /catch \{\s*return file;/.test(down) && /if \(longest <= maxEdge\) \{ bmp\.close\?\.\(\); return file; \}/.test(down),
      'a canvas that misbehaves now costs the GM their picture');
    // The copy said "Up to 5MB each", which stopped being what a GM runs into.
    check('the copy says what now happens',
      !/Up to 5MB each/.test(dashSrc) && /shrunk to\s*\$\{downscale\.MAX_EDGE\}px/.test(dashSrc),
      'the upload hint still promises a cap the GM rarely meets');
    // ── UI-AUDIT F59: the other half, in a different app ──
    //
    // F57 fixed campaign pictures. NPC portraits upload from apps/campaign and
    // were left at full size, painted at 34px and 120px. The check above reads
    // apps/gm-tools/index.html ONLY, so it could not have noticed.
    const campHtml = readFileSync(join(repoRoot, 'apps', 'campaign', 'index.html'), 'utf8');
    const campSrc = readFileSync(join(repoRoot, 'apps', 'campaign', 'campaign.js'), 'utf8');
    // THE PATH IS THE PART THE FINDING GOT WRONG. It proposed `js/downscale.js`,
    // and apps/campaign has no js/ directory - that tag 404s, leaves `downscale`
    // undefined, and every portrait upload dies in uploadPortrait's own catch.
    // Matched as a script tag with the absolute src, so a relative one fails
    // here rather than in a GM's browser.
    const campTagAt = (f) => campHtml.indexOf(`<script src="${f}"`);
    check('the campaign page loads the downscaler by absolute path',
      campTagAt('/apps/character-creator/js/downscale.js') > 0
      && campTagAt('/apps/character-creator/js/downscale.js') < campTagAt('campaign.js'),
      'downscale.js is missing, relative, or loads after campaign.js');
    // The same three-places rule as F57: the server reads this one header for
    // the R2 key's extension, the stored content_type and what it serves back.
    const portraitUp = functionBody(campSrc, 'async function uploadPortrait(');
    check('the portrait upload describes what it actually sends',
      !!portraitUp
      && /const body = await downscale\.toUpload\(file, PORTRAIT_MAX_EDGE\);/.test(portraitUp)
      && /'Content-Type': body\.type/.test(portraitUp)
      && !/'Content-Type': file\.type/.test(portraitUp),
      'the portrait request still names the original file type');
    // A PORTRAIT WANTS A SMALLER CAP THAN A MAP, and the cap is destructive -
    // the object in R2 is the only copy. A named constant beside the two paint
    // sizes, not a literal at the call site.
    const portraitCap = /const PORTRAIT_MAX_EDGE = (\d+);/.exec(campSrc);
    check('the portrait cap is named, and smaller than the picture cap',
      !!portraitCap && Number(portraitCap[1]) < 2048 && Number(portraitCap[1]) >= 360,
      'the portrait cap is missing, is the map cap, or is under the 120px square at DPR 3');
    // The helper's second parameter is what makes that possible. If it loses
    // its default, gm-tools starts uploading undefined-sized pictures.
    check('the helper still takes a cap and still has a default',
      /async function toUpload\(file, maxEdge = MAX_EDGE\)/.test(down),
      'toUpload no longer takes a per-caller cap, or lost its default');

    // ── THE BAR CARRIES THE CONTROLS (P5e, 2026-09-20) ──
    //
    // Measured on the Gear tab at 375 wide, 2,873px of page: Damage was off
    // screen by the halfway mark and the amount chips by the bottom, while the
    // fixed strip - the only band a thumb can always reach - held a read-only
    // roll result and NOTHING pressable.
    check('the combat controls live in the fixed bar',
      /<div id="play-roll-bar"[\s\S]{0,200}<div id="roll-line">/.test(src)
      && /\$\{playActionsHtml\(w\)\}/.test(src),
      'the bar is a text strip again and Damage scrolls away');
    // MOVED, NOT COPIED. Two amount strips would be two places to keep in
    // step, which is the drift this app paid for with the save list and the
    // pool widgets. There is one Damage button in the file.
    check('and they moved rather than being duplicated',
      (src.match(/onclick="quickDamage\(\)"/g) || []).length === 1
      && (src.match(/onclick="setPlayAmt\(/g) || []).length === 1,
      'there are two Damage buttons or two amount strips to keep in step');
    // A roll rewrites the LINE, never the bar - otherwise pressing Damage
    // rebuilds the button that was pressed, mid-press.
    check('a roll rewrites the line and not the bar',
      !/\$\('play-roll-bar'\)/.test(src) && (src.match(/\$\('roll-line'\)/g) || []).length === 3,
      'a roll rebuilds the controls it was triggered from');
    // The height is measured, not written down: the bar is two rows on a phone
    // and one on a laptop, so no constant is right at both.
    check('and the page reserves the height it actually has',
      /body\.play-mode \{ padding-bottom: calc\(var\(--play-bar-h, 72px\) \+ 12px\); \}/.test(css)
      && /--play-bar-h/.test(readFileSync(join(appDir, 'js', 'sticky.js'), 'utf8')),
      'play mode reserves a constant 72px for a bar that is 144px on a phone');

    // Column assignment. Every box the body holds must be placed.
    const colBlock = src.slice(src.indexOf('const BOX_COL'), src.indexOf('};', src.indexOf('const BOX_COL')));
    const assigned = [...colBlock.matchAll(/'?([a-z-]+)'?\s*:\s*'([abc])'/g)].map((m) => m[1]);
    check('there is a single column table', assigned.length > 0, 'BOX_COL is gone');

    // Titles come from box('...') calls; the name header is a template literal
    // and is deliberately unplaced, so only quoted titles are required to map.
    const titles = [...src.matchAll(/\bbox\('([^']+)'/g)].map((m) => m[1]);
    // THE POWERS BOX IS NOT IN THAT SWEEP, and that is why this section passed
    // while a box went unplaced. It chooses its title with a ternary -
    // `box(cond ? 'Powers' : 'Psionics &amp; Magic', ...)` - so its first
    // argument is not a plain literal and the pattern above sees neither side.
    // `psionics-magic` was mapped and `powers` was not.
    //
    // An unplaced box is not merely misplaced. `placeable` recurses PAST it to
    // the leaves and files each leaf into a column separately, which destroys
    // every `.power-row` wrapper inside it and drops the name of any power whose
    // name is bare text rather than a description button. Seen on a real sheet,
    // not predicted: 267 "no column for" warnings and no power names at all.
    // BOOK-INGEST-AUDIT F76.
    //
    // Both slugs are named rather than derived, because deriving them is what
    // failed: three attempts at a general pattern either missed the ternary or
    // scraped `field()` labels out of a neighbouring one. A narrow check that
    // runs beats a general one that cries wolf.
    titles.push('Powers', 'Psionics &amp; Magic');
    const slug = (t) => t.replace(/<[^>]*>/g, '').replace(/&amp;/g, ' ')
      .toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');
    const unplaced = titles.map(slug).filter((s) => !assigned.includes(s));
    check('every box in the body is assigned a column', unplaced.length === 0,
      `unplaced: ${unplaced.join(', ')} — an unplaced box lands wherever there is room`);

    // The skill boxes are built through a helper, so their titles are not literals
    // at the box() call. They are the widest thing on the sheet and must be in b.
    for (const s of ['class-skills', 'related-skills', 'secondary-skills']) {
      check(`${s} is in the wide column`, assigned.includes(s) && /(['"]?)class-skills\1?: 'b'/.test(colBlock) !== null
        && new RegExp(`'${s}': 'b'`).test(colBlock), `${s} is not in column b`);
    }

    // THE GRID PLACES THE STACKS. It used to place every box, and a box in a
    // grid row is as tall as the tallest box in that row - which is where the
    // 3281px of dead space came from. The child combinator is what keeps these
    // rules off the boxes INSIDE a stack: they carry data-col too, because it is
    // what stackColumns() reads, and they are not grid items.
    check('the stacks are placed by attribute, not by source order',
      /\.sheet-grid\.sheet-3 > \.sheet-col\[data-col="a"\] \{ grid-column: 1; \}/.test(css)
      && /\.sheet-grid\.sheet-3 > \.sheet-col\[data-col="b"\] \{ grid-column: 2; \}/.test(css)
      && /\.sheet-grid\.sheet-3 > \.sheet-col\[data-col="c"\] \{ grid-column: 3; \}/.test(css),
      'a column rule is missing');
    check('and the boxes themselves are not placed at all any more',
      !/\.sheet-grid\.sheet-3 \[data-col="[abc]"\] \{ grid-column/.test(css),
      'a bare [data-col] rule is back; it sets grid-column on things that are not grid items');

    // A stack, not a fourth grid. Rows are the whole of what this removes.
    check('a stack is a stack',
      /\.sheet-col \{ display: flex; flex-direction: column; gap: 14px; min-width: 0; \}/.test(css),
      '.sheet-col is not a flex column');
    check('and something builds them',
      /function stackColumns\(/.test(src)
      && /stackColumns\(\$\('app'\)\.querySelector\('\.sheet-body'\)\)/.test(src),
      'stackColumns is not defined, or render() never calls it');

    // Everything the pass moves is found BY data-col. A node without one is a
    // stray: filed under b with a console warning, which is a signal nobody is
    // watching for. These three are the nodes that are not plain boxes.
    check('the skills filter carries a column, or it drifts',
      /<div class="pick-filter noprint" data-col="b">/.test(src),
      '.pick-filter has no column and will be filed as a stray');
    check('the granted block is placed as a unit',
      /<div id="granted-block" class="sheet-grid" data-col="b"/.test(src),
      'refreshGranted() would write boxes into a container with no column of its own');
    check('and the hand-built Stage box is placed from the same table',
      /<div class="box noprint" data-box="stage" data-col="\$\{BOX_COL\.stage\}">/.test(src)
      && /stage: 'a'/.test(colBlock),
      'the Stage box is unplaced, or BOX_COL no longer decides where it goes');

    // Stage is the reason the stray path exists: it was built by hand rather
    // than through box(), so the title scan above never saw it, and it placed on
    // `auto` for as long as the three columns existed. Any future hand-built box
    // would do the same, so they are counted rather than trusted.
    const handBuilt = [...src.matchAll(/<div class="box(?:"|\s[^"]*")([^>]*)>/g)]
      .filter((m) => !m[1].includes('data-col')).map((m) => m[0]);
    check('every hand-built box carries one', handBuilt.length === 0,
      `unplaced: ${handBuilt.join(' ')} - box() adds data-col, hand-written markup does not`);

    // One column, and the tabs with it. The stacks dissolve rather than collapse,
    // or a tab whose boxes span two columns would be split down the page by an
    // assignment that has nothing left to say. The gap is the older bug: a
    // display: block panel stacked its margin-less boxes flush, measured 0, 0, 0
    // at 390px.
    const phoneBlock = css.slice(css.indexOf('@media (max-width: 820px)',
      css.indexOf('@media (max-width: 1180px)'))).slice(0, 400);
    check('a phone dissolves the stacks',
      /\.sheet-grid\.sheet-3 > \.sheet-col \{ display: contents; \}/.test(phoneBlock),
      'below 820px the stacks stay and split each tab down the page');
    check('and spaces the boxes of the open tab',
      /\.sheet-grid\.sheet-3 \.tabpanel\.on \{ display: flex; flex-direction: column; gap: 14px; \}/.test(phoneBlock),
      'the open tab stacks its boxes flush, with no rule between any two');

    // Prose keeps a measure; the sheet around it does not have to.
    check('prose is capped where it lives',
      /\[data-box="journal"\] \.box-body/.test(css) && /max-width: 66ch/.test(css),
      'the journal has no reading measure');

    // PAPER IS NOT A 1640px SCREEN. Every one of these was measured: without them
    // the printed sheet went from seven pages to eight.
    const printBlock = printCss(css);
    // Phase 4 held paper still by putting the body back to a plain block and
    // restoring the inner grids - the layout paper had before that phase.
    // Phase 7 replaced the hold with a real print layout: the body flows in
    // two columns and the inner grids dissolve into that flow. What both
    // versions assert is the same thing, which is that paper does not inherit
    // the three-column screen body.
    check('paper does not inherit the three-column body',
      /\.sheet-grid\.sheet-3 \{[\s\S]*?display: block;/.test(printBlock)
      && !/\.sheet-grid\.sheet-3 \{[\s\S]*?grid-template-columns: 296px/.test(printBlock),
      'print inherits the three-column screen grid');
    check('and lays itself out for a page instead',
      /\.sheet-grid\.sheet-3 \{[\s\S]*?columns: 2;/.test(printBlock),
      'paper has no print layout of its own');
    check('print releases the column assignments',
      /grid-column: auto;/.test(printBlock), 'boxes keep their screen columns on paper');
    // Multicol FLOWS one column into the next, so three stacks standing in the
    // way is three columns of boxes inside two columns of page.
    check('and dissolves the stacks so the boxes reach the flow',
      /\.sheet-grid\.sheet-3 > \.sheet-col \{ display: contents; \}/.test(printBlock),
      'the stacks survive into print and the multicol sees three items');
    check('print releases the prose cap',
      /\.box\[data-box\] \.box-body \{ max-width: none; \}/.test(printBlock),
      '66ch is narrower than a page column and runs the sheet long');
    check('and print keeps the pool value at a paper size',
      /\.vital \.val \{ font-size: 17px/.test(printBlock), 'a 44px pool value goes to paper');
  }

  // ---------- Presentation is a separate file ----------
  // sheet.js is data logic - fetch a character, derive its numbers, save edits,
  // reconcile play events. js/sheet-layout.js is what the sheet looks like. The
  // split only means anything if it keeps holding, so these pin it: the helpers
  // live in the module, sheet.js does not redefine them, and the module does not
  // learn about application state.
  section('Presentation is a separate file');
  {
    const sheet = readFileSync(appPath('sheet.js'), 'utf8');
    const layout = readFileSync(join(appDir, 'js', 'sheet-layout.js'), 'utf8');
    const html = readFileSync(appPath('sheet.html'), 'utf8');

    check('the module exposes one global, like derive.js and rules.js',
      /global\.sheetLayout = \{/.test(layout), 'sheetLayout is not exposed');
    check('and sheet.html loads it before sheet.js',
      html.indexOf('js/sheet-layout.js') > -1
      && html.indexOf('js/sheet-layout.js') < html.indexOf('src="sheet.js"'),
      'the module loads after the file that destructures it');

    for (const name of ['poolCard', 'box', 'field', 'boxSlug']) {
      check(`${name} is defined in the module`,
        new RegExp(`(function|const) ${name}\\b`).test(layout),
        `${name} is not in sheet-layout.js`);
      check(`and sheet.js does not redefine ${name}`,
        !new RegExp(`^\\s*(function|const) ${name}\\b`, 'm').test(sheet),
        `${name} has drifted back into sheet.js`);
    }

    // The whole point of the split. A presentation file that reads C is a second
    // place that knows what a character is, which is the thing being undone.
    // onclick strings are excluded: they are HTML the page evaluates, not a
    // dependency of this module.
    check('the module never reads application state',
      !/\bC\.(data|items|journal|cls|canWrite|isGm|playMode)\b/
        .test(layout.replace(/onclick="[^"]*"/g, '')),
      'sheet-layout.js reaches for C outside an onclick string');
    check('paintPool is handed the data instead of fetching it',
      /function paintPool\(key, data(, conflicts)?\)/.test(layout),
      'paintPool still reaches for C');
    // `poolData()` since BOOK-INGEST-AUDIT F74: still ONE place, and it hands
    // back C.data itself unless a second form's pools are showing.
    check('and sheet.js supplies it in one place, not seven',
      (/const paintPool = \(key\) => sheetLayout\.paintPool\(key, C\.data[^)]*\);/.test(sheet)
        || (/const paintPool = \(key\) => sheetLayout\.paintPool\(key, poolData\(\), C\.conflicts\);/.test(sheet)
          && /if \(!formOn\(\)\) return C\.data;/.test(sheet))),
      'each call site supplies the character data separately');
  }

  // ---------- The wizard rail ----------
  // The stepper is a sticky rail of ten labels with a summary strip under it.
  // These pin the parts that go wrong quietly.
  //
  // The first one is the reason this section exists. The redesign brief that
  // produced this phase specified `repeat(7, 1fr)` and "seven progress bars",
  // twice, because it was written against a seven-step wizard that has not
  // existed for a long time. A hardcoded column count does not fail loudly when
  // the step list changes - it just puts the last steps off the end of the grid.
  // A POWER'S POOL IS DECIDED IN ONE PLACE, and the render path and the spend path
  // both use it.
  //
  // They used to answer the question separately, and disagreed. The row renderer
  // put `data-pool="ppe"` on a Talent's use button, so it enabled and disabled off
  // P.P.E.; `usePower` carried its own copy - `p.type === 'spell' ? 'ppe' : 'isp'`
  // - which sent every non-spell to I.S.P. Pressed on a real sheet, the button
  // spent NOTHING: a Nightbane has no `isp_current`, so the function returned early
  // on a null pool, with P.P.E. unchanged and no message. BOOK-INGEST-AUDIT F76's
  // outcome note had reported it working, from seeing it render and enable.
  section('A power spends the pool its button says it spends');
  {
    const sheetSrc = readFileSync(appPath('sheet.js'), 'utf8');
    const defs = (sheetSrc.match(/function powerPool\(/g) || []).length;
    check('one function decides which pool a power spends', defs === 1, `defined ${defs} times`);
    const use = sheetSrc.slice(sheetSrc.indexOf('async function usePower('),
      sheetSrc.indexOf('async function usePower(') + 900);
    check('and the spend path reads it', /powerPool\(p\)/.test(use), use.slice(0, 200));
    // THE SHAPE THAT WAS WRONG, named so it cannot come back under another name.
    // Any ternary choosing between the two pool strings is a second answer to the
    // question powerPool exists to answer once.
    //
    // Line comments are stripped first. The comment above powerPool quotes the old
    // line on purpose - it is the record of what went wrong - and scanning the raw
    // source counted that quotation as a second rule, which is the check failing
    // on its own explanation. Found by running it, not predicted.
    const code = sheetSrc.replace(/\/\/.*$/gm, '');
    const second = [...code.matchAll(/\?\s*'ppe'\s*:\s*'isp'|\?\s*'isp'\s*:\s*'ppe'/g)];
    check('and nothing else in the sheet decides it with its own ternary', second.length === 0,
      `${second.length} other ternary choosing between ppe and isp`);
  }

  // A PERMANENT P.P.E. SPEND LOWERS THE MAXIMUM EVERYWHERE THE MAXIMUM IS SHOWN.
  //
  // Migration 065 records P.P.E. burned out of the base as `ppe_base_spent` and
  // leaves `ppe_max` as the ROLLED value, so the validator and the level-up and
  // re-roll paths that read or rewrite `ppe_max` cannot refuse or erase the spend.
  // The cost of that design is that every reader wanting the maximum a character
  // can actually FILL has to subtract. Three readers on the sheet did not, and
  // each is pinned here; the server's PATCH clamp is pinned beside them.
  // BOOK-INGEST-AUDIT F101.
  section('A permanent P.P.E. spend lowers the maximum wherever it is shown');
  {
    const layoutSrc = readFileSync(join(appDir, 'js', 'sheet-layout.js'), 'utf8');
    // The file hangs its exports on the global it is handed, so it can RUN here.
    const g = {};
    new Function(`return (globalThis) => { ${layoutSrc} }`)()(g);
    const { poolMax } = g.sheetLayout;
    check('sheet-layout exposes poolMax', typeof poolMax === 'function');
    // GUARDED, so a missing function FAILS the check above rather than throwing
    // on the next line and taking the rest of the suite down with it. Found by
    // running this against the code before poolMax existed: it crashed Node.
    const pm = typeof poolMax === 'function' ? poolMax : () => Symbol('missing');
    check('P.P.E. subtracts the permanent spend', pm({ ppe_max: 13, ppe_base_spent: 5 }, 'ppe') === 8);
    check('and a character who has spent nothing is unchanged', pm({ ppe_max: 13 }, 'ppe') === 13
      && pm({ ppe_max: 13, ppe_base_spent: 0 }, 'ppe') === 13);
    check('and it never goes below zero', pm({ ppe_max: 4, ppe_base_spent: 10 }, 'ppe') === 0);
    check('no other pool is touched by a P.P.E. spend',
      pm({ isp_max: 30, ppe_base_spent: 5 }, 'isp') === 30
      && pm({ hp_max: 20, ppe_base_spent: 5 }, 'hp') === 20);
    check('and an absent maximum stays absent rather than becoming a number',
      pm({ ppe_base_spent: 5 }, 'ppe') === undefined);

    // The three readers. Each used to read `_max` straight off the data.
    const sheetSrc = readFileSync(appPath('sheet.js'), 'utf8');
    const paint = layoutSrc.slice(layoutSrc.indexOf('function paintPool('), layoutSrc.indexOf('function paintPool(') + 200);
    check('the live repaint reads the effective maximum', /poolMax\(data, key\)/.test(paint), paint);
    // `pd` is poolData() - the character, or it with a second form's pools (F74).
    check('the first render reads it', /poolCard\(key, label,[^;]*poolMax\((c|pd), key\)/.test(sheetSrc));
    const rest = sheetSrc.slice(sheetSrc.indexOf('function restPreview('), sheetSrc.indexOf('function updateRestPreview('));
    // `pd` again: a second form active rests its own pools to its own maxima.
    check('and the rest-recovery preview reads it, so resting cannot preview a refill past it',
      /poolMax\(C\.data, key\)/.test(rest) || /const pd = poolData\(\);[\s\S]*poolMax\(pd, key\)/.test(rest), rest.slice(0, 300));

    // And the server, which is what actually stops a refill past the spend.
    const idSrc = readFileSync(join(appDir, '..', '..', 'functions', 'api', 'character-creator',
      'characters', '[id].js'), 'utf8');
    check('the PATCH clamp reads the spend', /SELECT[^']*ppe_base_spent[^']*FROM characters/.test(idSrc));
    check('and subtracts it from the P.P.E. maximum before clamping',
      /field === 'ppe_current'[\s\S]{0,200}max - \(Number\(current\?\.ppe_base_spent\)/.test(idSrc));
  }

  // A TALENT EARNED AT LEVEL-UP CAN BE CHOSEN, THERE OR LATER.
  //
  // BOOK-INGEST-AUDIT F76 banked Talent grants on a level-up and never put them on
  // the proposal, and the sheet loaded no Talent catalog. So the free Talents at
  // levels four, seven, ten and twelve banked with no picker, and the banked-picks
  // panel - two-way, spell or else psionic - offered PSIONIC POWERS to spend them
  // on, which the server then refused. Nothing could spend one.
  //
  // RUN, not matched: the three functions are cut out of sheet.js and executed
  // against a stub `C`, because every earlier defect in this feature read correct
  // as text.
  section('A Talent earned at level-up can be chosen, then or later');
  {
    const cls = { talents: { talents_starting: 1, talents_schedule: [
      { level: 4, count: 1 }, { level: 7, count: 1 }] } };
    const prop = buildProposal({ level: 3, hp_max: null, sdc_max: null, skills: [] }, cls, 4);
    check('the level-up proposal carries the Talent grant',
      prop.talent_picks?.applicable === true && prop.talent_picks?.total === 1,
      JSON.stringify(prop.talent_picks));

    const sheetSrc = readFileSync(appPath('sheet.js'), 'utf8');
    const cut = (from, to) => {
      const a = sheetSrc.indexOf(from), b = sheetSrc.indexOf(to, a);
      return a >= 0 && b > a ? sheetSrc.slice(a, b) : '';
    };
    const src = cut('function powerPickerBlock(', '// Every power slot the level-up panel')
      + cut('function pendingPowersPanel(', 'async function claimPowers(');
    check('the sheet catalog load keeps the Talents', /C\.talentCatalog = catalogs\.talents/.test(sheetSrc));

    const C = {
      data: { campaign_system: 'nightbane', powers: [{ name: 'Held Talent', type: 'talent' }],
              ppe_max: 30, ppe_base_spent: 10 },
      cls, spellCatalog: [], psiCatalog: [{ name: 'Sixth Sense', category: 'Sensitive', system: null }],
      talentCatalog: [
        { name: 'Soul Shield', tier: 'common', system: 'nightbane', min_character_level: null, acquire_ppe: 6 },
        { name: 'Fifth-Level Talent', tier: 'common', system: 'nightbane', min_character_level: 5, acquire_ppe: 15 },
        { name: 'Held Talent', tier: 'common', system: 'nightbane', min_character_level: null, acquire_ppe: 5 },
        { name: 'Other System', tier: 'common', system: 'rifts', min_character_level: null, acquire_ppe: 5 },
      ],
      claimingPowers: true,
      pendingPowers: [{ kind: 'talent', granted_at_level: 4, slot: 0, count: 1 }],
      pendingPowersTotal: 1,
    };
    const esc = (s) => String(s ?? '');
    let fns = null;
    try {
      // poolMax is the sheet-layout helper, stubbed with its P.P.E. rule.
      const poolMax = (data, key) => (data[key + '_max'] == null ? null
        : data[key + '_max'] - (key === 'ppe' ? Number(data.ppe_base_spent) || 0 : 0));
      fns = new Function('C', 'escHtml', 'globalThis', 'poolMax',
        `${src}\nreturn { powerPickerBlock, pendingPowersPanel };`)(C, esc, {}, poolMax);
    } catch (e) {
      check('the pickers run outside the page', false, e.message);
    }
    const options = (html) => [...html.matchAll(/<option value="([^"]+)"/g)].map((m) => m[1]);

    const up = fns ? fns.powerPickerBlock(prop) : '';
    check('the level-up picker shows a Talents block', /Talents <span/.test(up), up.slice(0, 200));
    check('and its select is tagged as a talent, so the server consumes the talent grant',
      /data-kind="talent"/.test(up));
    check('and it offers Talents - not psionic powers, not one already held, not another system',
      JSON.stringify(options(up)) === '["Soul Shield"]', JSON.stringify(options(up)));

    const banked = fns ? fns.pendingPowersPanel() : '';
    check('the banked panel offers Talents for a banked Talent grant, not psionic powers',
      JSON.stringify(options(banked)) === '["Soul Shield"]', JSON.stringify(options(banked)));
    check('and tags it a talent too', /data-kind="talent"/.test(banked));

    // The server refuses a Talent whose min_character_level is above the grant's
    // level, so the picker must not offer one: a level-7 grant can have it.
    C.pendingPowers = [{ kind: 'talent', granted_at_level: 7, slot: 0, count: 1 }];
    const later = fns ? fns.pendingPowersPanel() : '';
    check('a fifth-level Talent waits for a grant from level five or later',
      JSON.stringify(options(later)) === '["Soul Shield","Fifth-Level Talent"]', JSON.stringify(options(later)));

    // And nothing moved for the two kinds that already worked.
    C.pendingPowers = [{ kind: 'psionic', granted_at_level: 4, slot: 0, count: 1, categories: null }];
    const psi = fns ? fns.pendingPowersPanel() : '';
    check('a banked psionic grant still offers psionic powers',
      JSON.stringify(options(psi)) === '["Sixth Sense"]', JSON.stringify(options(psi)));

    // TALENT PURCHASES (BOOK-INGEST-AUDIT F101): the same pool, a different grant
    // kind, and the two things a player needs before choosing - each price, and
    // what is left of the base to pay it from (30 rolled - 10 spent = 20).
    const buyer = { talents: { talents_starting: 1, talents_purchases_per_level: 2 } };
    const buyProp = buildProposal({ level: 3, hp_max: null, sdc_max: null, skills: [] }, buyer, 4);
    const buyUp = fns ? fns.powerPickerBlock(buyProp) : '';
    check('the level-up offers Talents to buy, tagged as purchases',
      /Talents to buy/.test(buyUp) && /data-kind="talent_purchase"/.test(buyUp), buyUp.slice(0, 300));
    check('with each Talent\'s price', /Soul Shield \(6 P\.P\.E\. to buy\)/.test(buyUp), buyUp.slice(0, 600));
    check('and what is left of the base to pay from', /20 P\.P\.E\. left to spend/.test(buyUp));

    C.claimingPowers = false;
    C.pendingPowers = [{ kind: 'talent', granted_at_level: 4, slot: 0, count: 1 },
                       { kind: 'talent_purchase', granted_at_level: 4, slot: 0, count: 2 }];
    C.pendingPowersTotal = 3;
    const banner = fns ? fns.pendingPowersPanel() : '';
    check('the banked banner counts purchases apart from powers that are owed',
      /1 unspent power · 2 Talent purchases available/.test(banner), banner.replace(/\s+/g, ' ').slice(0, 200));
    C.claimingPowers = true;
    const buyBanked = fns ? fns.pendingPowersPanel() : '';
    check('and the banked panel offers them priced, tagged as purchases',
      /data-kind="talent_purchase"/.test(buyBanked) && /Soul Shield \(6 P\.P\.E\. to buy\)/.test(buyBanked));
  }

  section('The wizard rail');
  {
    const app = readFileSync(join(appDir, 'app.js'), 'utf8');
    const css = readFileSync(join(appDir, 'styles.css'), 'utf8');
    const html = readFileSync(join(appDir, 'index.html'), 'utf8');

    const stepCount = (app.match(/const STEPS = \[([^\]]*)\]/)?.[1] || '')
      .split(',').map((x) => x.trim()).filter(Boolean).length;
    const cols = Number(css.match(/\.step-rail \{[\s\S]*?repeat\((\d+), 1fr\)/)?.[1]);
    check('the rail has one column per step', cols === stepCount,
      `STEPS is ${stepCount} and the grid is ${cols}; the brief said 7`);

    check('the step number is its own element, not text in the label',
      /const stepNum = \(i\) =>[\s\S]*?class="n"/.test(app), 'stepNum is gone');
    check('and it is padded, so step ten does not shift its column',
      /padStart\(2, "0"\)/.test(app), 'the number is not two digits');

    // The N/A step's full opacity is load-bearing and measured: 1.84:1 at 0.4,
    // 3.49 at 0.75, 4.45 at 0.9. Nothing short of 1 clears the bar.
    const naRule = css.match(/\.step-rail \.st\.na \{[^}]*\}/)?.[0] || '';
    check('a step that does not apply is never dimmed',
      naRule.length > 0 && !/opacity/.test(naRule),
      'opacity is back on .st.na; the comment above it says what that measures');
    check('it is marked by a dashed rule instead',
      /border-bottom-style: dashed/.test(naRule), '.na has lost its dashed border');

    // The strip carries what used to be two paragraphs under the stepper.
    check('the greyed-step sentence lives in the summary strip',
      /class="ws-note"/.test(app) && !/class="attr-note"[^`]*does not apply/.test(app),
      'the N/A sentence is still its own paragraph');
    check('and so does the autosave warning',
      /ws-note warn err/.test(app), 'the draft-conflict notice is outside the strip');

    // Derived, stored nowhere new - the plan's constraint.
    const summary = app.slice(app.indexOf('function summaryItems()'),
      app.indexOf('function renderStepper()'));
    check('the summary is built from wizard state', summary.length > 0, 'summaryItems is gone');
    check('and stores nothing of its own',
      !/localStorage|sessionStorage|S\.summary/.test(summary),
      'the summary strip has grown its own state');
    check('every settled item links back to its step',
      /onclick="goStep\(\$\{step\}\)"/.test(summary), 'summary items are not links back');

    // Gold in Palladium, credits in Rifts. The brief said "credits".
    check('money is labelled by the system, not called credits',
      /rules\.currencyLabel\(S\.system\)/.test(summary) && !/'Credits'/.test(summary),
      'the strip hardcodes a currency name');

    // The rail sticks under a header whose height is measured, not assumed.
    check('sizeSticky is shared rather than copied',
      existsSync(join(appDir, 'js', 'sticky.js')), 'js/sticky.js is missing');
    const sheet = readFileSync(appPath('sheet.js'), 'utf8');
    check('and neither page keeps its own copy',
      !/function sizeSticky\(/.test(sheet) && !/function sizeSticky\(/.test(app),
      'a page still defines its own sizeSticky');
    for (const page of ['index.html', 'sheet.html']) {
      check(`${page} loads it`,
        readFileSync(appPath(page), 'utf8').includes('js/sticky.js'),
        `${page} sticks against an unset --header-h`);
    }
    check('the wizard measures the header on render',
      /sticky\.sizeSticky\(\);/.test(app), 'the wizard never measures the header');

    // On a phone the labels go and the bars remain. font-size: 0 rather than
    // display: none, so the button keeps its accessible name.
    const phone = css.slice(css.indexOf('@media (max-width: 900px)'));
    check('the labels are hidden without removing them from the accessibility tree',
      /font-size: 0/.test(phone) && !/\.st \{[^}]*display: none/.test(phone),
      'the phone rail hides the steps outright');
    check('and every step still has a visible track',
      /border-bottom-color: var\(--border\)/.test(phone),
      'unreached steps are transparent, so the phone shows gaps rather than ten bars');

    check('the wizard has its own container',
      /\.wrap\.wrap-wizard \{ max-width: 1180px; \}/.test(css) && /wrap wrap-wizard/.test(html),
      'the rail is back inside a 900px container it does not fit');
  }

  // ---------- The GM dashboard ----------
  // The roster and the GM notes share a row; the journal runs full width under
  // them. Two of these pin things the redesign brief got wrong, so they are
  // worth more than the layout they describe.
  // "Removed X. Undo" in place of confirm() (plan PR 7). What can go wrong
  // silently: a page that calls undoable() without loading the script throws
  // on the click, and a delete that quietly goes back to confirm() - or a
  // character delete that quietly LOSES its confirm - passes every other check.
  section('Undo instead of confirm for one-row deletes');
  {
    const toast = readFileSync(join(appDir, 'js', 'undo-toast.js'), 'utf8');
    check('the helper waits before sending, and sends on leaving the page',
      /setTimeout\(\(\) => send\(p, false\), WINDOW_MS\)/.test(toast)
        && /addEventListener\('pagehide', \(\) => \{ if \(pending\) send\(pending, true\); \}\)/.test(toast)
        && /if \(pending\) send\(pending, false\);/.test(toast),
      'undo-toast.js no longer delays the request, commits on pagehide, or keeps one pending');
    check('and a failed request puts the row back',
      /catch \(err\) \{[\s\S]{0,200}p\.restore\(\)/.test(toast),
      'a failed delete would leave a row that looks deleted and is not');
    for (const [page, script, fns] of [
      ['character-sheet', 'sheet.js', ['removeItem', 'removeVessel']],
      ['campaign', 'campaign.js', ['removeEntry', 'deleteNpc', 'dropItem']],
      ['gm-tools', 'dashboard.js', ['deletePicture']],
    ]) {
      const html = readFileSync(join(repoRoot, 'apps', page, 'index.html'), 'utf8');
      const src = readFileSync(join(repoRoot, 'apps', page, script), 'utf8');
      const at = (s) => html.indexOf(s);
      check(`${page} loads the helper before ${script}`,
        at('/apps/character-creator/js/undo-toast.js') > 0
          && at('/apps/character-creator/js/undo-toast.js') < at(`src="${script}"`),
        `${page}/index.html does not load undo-toast.js ahead of ${script}`);
      for (const fn of fns) {
        const body = (src.match(new RegExp(`function ${fn}\\([^)]*\\) \\{[\\s\\S]*?\\n\\}`)) || [''])[0];
        check(`${script} ${fn}() uses the undo toast, not confirm()`,
          /undoable\(\{/.test(body) && !/confirm\(/.test(body) && /keepalive/.test(body),
          `${fn} is back on confirm(), or its request would not survive the page closing`);
      }
    }
    const sheetSrc = readFileSync(join(repoRoot, 'apps', 'character-sheet', 'sheet.js'), 'utf8');
    const dashSrc = readFileSync(join(repoRoot, 'apps', 'gm-tools', 'dashboard.js'), 'utf8');
    check('and deleting a whole character, or a whole GM page, still asks first',
      /confirm\(`Delete \$\{c\.name\} \(level/.test(sheetSrc) && /confirm\(`Delete "\$\{D\.entry\.title\}"/.test(dashSrc),
      'a character or a GM page can now be deleted without a question');
  }

  section('The GM dashboard');
  {
    const js = readFileSync(appPath('dashboard.js'), 'utf8');
    const css = readFileSync(join(appDir, 'styles.css'), 'utf8');
    const html = readFileSync(appPath('dashboard.html'), 'utf8');

    check('the dashboard has its own container',
      /\.wrap\.wrap-dash \{ max-width: 1280px; \}/.test(css), 'wrap-dash is gone');
    check('and dashboard.html asks for it',
      /<main class="wrap wrap-dash">/.test(html), 'the dashboard is back on the 900px container');

    check('the roster and the rail sit side by side',
      /\.dash-grid \{[\s\S]*?grid-template-columns: minmax\(0, 1fr\) 380px;/.test(css),
      'the dash grid is gone');
    check('and stack below 1100px',
      /@media \(max-width: 1100px\) \{[\s\S]*?\.dash-grid \{ grid-template-columns: 1fr; \}/.test(css),
      'the rail never collapses');

    // The notes panel is GM-only. A player gridded against it would get a 380px
    // column of nothing beside a squeezed roster, so the class is conditional.
    check('the grid is only applied when there is a rail to fill',
      /class="\$\{D\.isGm \? 'dash-grid' : ''\}"/.test(js),
      'a player gets a two-column layout with an empty rail');
    check('and the notes panel is still GM-only',
      /\$\{D\.isGm \? `/.test(js), 'the GM notes are no longer gated');

    // XP to CHOSEN characters (plan PR 6). The award reads the ticked party,
    // never the whole roster; the tick is stored as who is LEFT OUT, so a
    // roster refresh or a new arrival cannot silently drop someone; and an
    // NPC never gets a tick, since the award skips NPCs whatever is ticked.
    check('XP goes to the ticked party members, not the whole roster',
      /const party = xpTargets\(\);/.test(js)
        && /xpTargets = \(\) => xpParty\(\)\.filter\(\(c\) => !D\.xpSkip\.has\(c\.id\)\)/.test(js)
        && /xpParty = \(\) => D\.roster\.filter\(\(c\) => c\.kind !== 'npc'\)/.test(js),
      'the XP award no longer honours the ticks, or has started paying NPCs');
    check('and an NPC row has no tick to offer',
      /D\.isGm && c\.kind !== 'npc'\s*\? `<input type="checkbox" class="gm-xp-pick/.test(js),
      'the roster offers an XP tick the award would ignore');

    // Source order: notes before journal, which is the "surface it" change.
    check('the notes come before the journal',
      js.indexOf('gm-notes') < js.indexOf('Campaign journal'),
      'the notes panel is still below the journal');

    // Read DOWN the column, so the digits line up. This one never had a
    // font-family, so phase 2 - which moved rules that named a face - did not
    // touch it, and it kept proportional figures. Measured at `normal` on the
    // live page before the fix.
    const pools = css.match(/\.pools-cell \{[^}]*\}/)?.[0] || '';
    check('the pools column has tabular figures',
      /font-variant-numeric: tabular-nums/.test(pools),
      'pools read down a column with proportional digits');
    // THE FACE THIS PINS MOVED ON 2026-09-20 and the claim got stronger rather
    // than weaker. Board & Tissue sets every run of figures in a real mono face
    // instead of the condensed display face, so "like every other numeric
    // column" now means --font-mono. font-stretch: 75% is unchanged and still
    // asserted: Martian Mono's width axis starts at 75%, so the same
    // declaration that gave Saira its condensed instance gives Martian Mono its
    // narrowest one, which is what keeps a 44px pool value inside its card.
    check('and the figure face, like every other numeric column',
      /var\(--font-mono\)/.test(pools) && /font-stretch: 75%/.test(pools),
      'the pools column is the one numeric column still on the display face');
  }

  // ---------- The printed sheet ----------
  // Paper is not a screen, and every rule here exists because a screen decision
  // reached it and cost pages. The numbers in the comments are from real print
  // renders, so a change that undoes one of these shows up as a longer sheet
  // rather than as a failing assertion - which is why these pin the mechanism.
  section('The printed sheet');
  {
    const css = readFileSync(join(appDir, 'styles.css'), 'utf8');
    const print = printCss(css);

    // Multicol, not grid. A grid row is as tall as its tallest box, so a long
    // list beside a short one leaves the rest of the row blank; measured at five
    // pages either way before this changed.
    check('the body flows in columns on paper',
      /\.sheet-grid\.sheet-3 \{[\s\S]*?columns: 2;/.test(print),
      'paper is back on a grid, which leaves a row as tall as its tallest box');
    check('and the inner grids are plain blocks so the flow is continuous',
      /\.sheet-grid\.sheet-3 \.tabpanel > \.sheet-grid \{ display: block; \}/.test(print),
      'the inner grids still lay out on their own');

    // The page-count driver.
    check('short boxes stay whole',
      /\.sheet-grid\.sheet-3 \.box \{ break-inside: avoid;/.test(print),
      'a six-row box may now split for no reason');
    const longLists = ['equipment', 'class-skills', 'related-skills',
      'secondary-skills', 'psionics-magic', 'journal'];
    const missing = longLists.filter((b) =>
      !new RegExp(`\\.sheet-grid\\.sheet-3 \\.box\\[data-box="${b}"\\]`).test(print));
    check('and the long lists are allowed to split', missing.length === 0,
      `still unbreakable: ${missing.join(', ')} — an unbreakable long list pushes a page and leaves it blank`);
    // Specificity, not order alone: .sheet-grid.sheet-3 .box is (0,3,0) and the
    // exception must match it or the exception silently loses.
    check('the exception can actually win',
      print.indexOf('break-inside: auto') > print.indexOf('.sheet-grid.sheet-3 .box { break-inside: avoid'),
      'the break-inside exception is stated before the rule it overrides');

    // Screen decisions that must not reach paper. Each of these was measured.
    check('the 44px pool value does not go to paper',
      /\.vital \.val \{ font-size: 17px/.test(print), 'a 44px pool value prints');
    check('nor the prose cap',
      /\.box\[data-box\] \.box-body \{ max-width: none; \}/.test(print),
      '66ch is narrower than a page column and runs the sheet long');
    check('nor the three-column assignments',
      /grid-column: auto;/.test(print), 'boxes keep their screen columns on paper');
    check('the pools know there are five of them',
      /\.vitals \{ grid-template-columns: repeat\(5, 1fr\); \}/.test(print),
      'auto-fit gives eight tracks for five pools on a page');

    // The pool value reaches paper through the <b>, because print hides inputs.
    check('every pool still prints its number',
      /\.vital \.val b \{ display: inline !important; \}/.test(print),
      'the pools print blank');
    check('and the screen affordances do not',
      /\.vital \.bar, \.vital \.steppers \{ display: none !important; \}/.test(print),
      'the bar or the steppers print');

    check('the tab bar is hidden explicitly, not by the button rule',
      /\.tabbar \{ display: none !important; \}/.test(print),
      'the tab bar is a div and the blanket button rule does not reach it');

    // The same trap as the pool <b> above, and it was walked straight into: a
    // power name with a description became a <button> so it could be pressed,
    // and the blanket rule deleted every spell name from the printed sheet —
    // a P.P.E. column with nothing left to say what it was for. A print render
    // found it and nothing on screen could have. The fixture that caught it is
    // test/fixtures/print-power-desc.html; plan 20 has the rest.
    // `print` above is the LAST @media print block, which is the one that lays
    // the paper out in columns. There are six in this stylesheet, and the power
    // rules belong in the sheet's own block beside `.power-row .cost` rather
    // than in the layout one — so these three read every print block.
    const everyPrint = css.split('@media print').slice(1).join('\n@media print ');
    check('a power name that became a button still prints',
      /\.power-toggle \{ display: inline !important;/.test(everyPrint),
      'the blanket button rule is deleting spell names from paper');
    check('but its caret does not, being an affordance',
      /\.power-toggle::after \{ display: none !important; \}/.test(everyPrint),
      'a press-me caret prints beside every named power');
    check('and a held power description stays off paper',
      /\.power-desc \{ display: none !important; \}/.test(everyPrint),
      'about 8,000 characters of book prose per character, roughly three pages');
  }

  // ---------- Trackable resources ----------
  // A countable thing a class hands out that is not a pool, a skill or a power.
  // It is a FRONTMATTER KEY, not a database column: the markdown is the class,
  // and a column populated at runtime would be class data the repo cannot
  // rebuild - which is the one thing drift-check and repo-vs-live exist to
  // assert. See CHANGE-PLAN.md phase 8, which specified the column.
  // Play mode was a second render path - renderPlay() drew the same skills, saves
  // and combat bonuses again in a 720px single column. It is a MODE on the sheet
  // now. What these pin is the shape that makes that safe, because the failure
  // would be silent: a second path that drifts from the first is exactly the bug
  // phase 3 already fixed once, when two pool widgets disagreed.
  section('Play mode is a mode, not a layout');
  {
    const sheet = readFileSync(appPath('sheet.js'), 'utf8');
    const css = readFileSync(join(appDir, 'styles.css'), 'utf8');

    check('there is no second render path',
      !/function renderPlay\(/.test(sheet), 'renderPlay() is back');
    check('and render() does not branch on the mode',
      !/if \(C\.playMode\) \{ \$\('app'\)\.innerHTML/.test(sheet),
      'render() dispatches to a second path again');
    check('the play layout is gone from the stylesheet',
      !/\.play-view[\s.{,]/.test(css.replace(/\/\*[\s\S]*?\*\//g, '')),
      'a .play-view rule survives outside a comment');

    // Switching modes must not rebuild the page: a re-render replaces every
    // input, and the one thing a mode toggle must never cost is a half-typed
    // note. Same rule pickTab already follows.
    // This is the one that failed on the first Linux run, and it failed in the
    // right direction: the rest of the file contains `render()`.
    const togglePlayBody = functionBody(sheet, 'function togglePlay()');
    check('togglePlay()\'s body can be located', togglePlayBody !== null,
      'no line-initial closing brace after the signature - the check below would read the whole file');
    const toggle = togglePlayBody ?? '';
    check('toggling the mode is a class flip, not a re-render',
      !/\brender\(\)/.test(toggle) && /syncPlayChrome\(\)/.test(toggle),
      'togglePlay re-renders and will eat a half-typed note');

    // THE PRINT RULE IS WHY THE ROWS ARE NOT BUTTONS. `button` is hidden
    // outright on paper, so a skill row that BECAME a button would have
    // disappeared from the printed sheet. The control sits BESIDE the number.
    check('the roll control is a button, so a keyboard can reach it',
      /<button type="button" class="roll-btn/.test(sheet),
      'the roll control is not a button');
    check('and the rows it sits in are still rows',
      /<tr class="skill-row">/.test(sheet) && /<div class="field">/.test(sheet),
      'a row became a control and will not print');
    check('print hides everything play mode adds',
      /@media print \{ #play-controls, #play-roll-bar, \.roll-btn \{ display: none !important; \} \}/.test(css),
      'the print block no longer hides the play blocks');
    // A fourth column for the control moved the printed sheet - the +%/Lvl
    // column shifted 4.5pt left on every skill table. Measured, and the reason
    // the control lives INSIDE the % cell instead.
    check('the skill table gained no column for the control',
      !/roll-col/.test(sheet) && /<th>Skill<\/th><th class="num">\+%\/Lvl<\/th><th class="num">%<\/th>/.test(sheet),
      'the roll control took a table column again and will move the printout');
    check('so the skill note still spans exactly three',
      /<tr class="skill-note"><td colspan="3">/.test(sheet),
      'the note colspan no longer matches the table');

    check('the mode is what reveals the play blocks',
      /body:not\(\.play-mode\) #play-controls,[\s\S]{0,80}?#play-roll-bar \{ display: none; \}/.test(css),
      'the play blocks are not gated on body.play-mode');
    check('and the roll controls',
      /body\.play-mode \.roll-btn \{ display: inline-flex/.test(css),
      'the roll controls are not gated on body.play-mode');

    // THE BARE PERCENTILE. Every other d100 on this sheet is a skill's own
    // percentage, so both the roll bar and the session-log note could assume a
    // target and read `r.target` straight into a string. The roll a G.M. asks
    // for by name has none, and one shared branch prints `vs null%` in the bar
    // and `vs null% — fail` in the log - a verdict against a target nobody set,
    // written into the character's permanent record.
    //
    // Four things, and the last two are the ones that would go quiet: the
    // control exists, it rolls with no target, BOTH readers handle the null,
    // and the button is inside #play-controls rather than loose in the sheet,
    // which is what keeps it off paper and out of sheet mode without a rule of
    // its own.
    const rollNoteBody = functionBody(sheet, 'function rollNote(');
    const rollBarBody = functionBody(sheet, 'function rollBarHtml()');
    // One roll as the bar draws it. UI-AUDIT F44 split the bar into the latest
    // line plus a history of ten, so the per-roll rendering - and the null
    // target it must read - moved out of rollBarHtml into this.
    const rollLineBody = functionBody(sheet, 'function rollLineHtml(');
    const recordRollBody = functionBody(sheet, 'function recordRoll(');
    const playControlsBody = functionBody(sheet, 'function playControlsHtml(');
    const playActionsBody = functionBody(sheet, 'function playActionsHtml(');
    check('all six bodies the percentile checks read can be located',
      rollNoteBody !== null && rollBarBody !== null && rollLineBody !== null
      && recordRollBody !== null && playControlsBody !== null && playActionsBody !== null,
      'a signature moved - the checks below would read the whole file and pass vacuously');
    check('the sheet can roll a bare percentile',
      /function rollPercentile\(\)/.test(sheet),
      'rollPercentile is gone');
    check('and it rolls with no target and no verdict',
      /recordRoll\('percentile', 'Percentile', \{ die: 100, roll, target: null, ok: null \}\)/.test(sheet),
      'the bare percentile acquired a target, which is a verdict nobody rolled');
    check('the roll bar reads the null target rather than printing it',
      /r\.target == null/.test(rollLineBody ?? ''),
      'the roll bar will show "vs null%"');
    check('and so does the note that reaches the session log',
      /r\.target == null/.test(rollNoteBody ?? ''),
      'a percentile will be logged as "vs null% — fail"');
    check('a percentile is persisted like every other roll',
      /kind === 'percentile'/.test(recordRollBody ?? ''),
      'the percentile never reaches the session log');
    // It moved out of #play-controls and into the fixed bar (P5e), so the
    // containment this asserted is no longer where it lives. What the check was
    // FOR is unchanged and is asserted directly instead: whichever block holds
    // it, print must hide that block. Both are named in the same print rule,
    // so the button cannot reach paper from either.
    check('the percentile lives in the bar that never scrolls away',
      /rollPercentile\(\)/.test(playActionsBody ?? '')
      && !/rollPercentile\(\)/.test(playControlsBody ?? ''),
      'the percentile is back up the page with the things that scroll off');
    check('and print hides the block it lives in',
      /@media print \{ #play-controls, #play-roll-bar, \.roll-btn \{ display: none !important; \} \}/.test(css),
      'the percentile button will reach paper');

    // SHIPPED BROKEN ONCE. .skill-table is `table-layout: fixed` with its last
    // numeric column pinned at 40px, so a 44px control in that cell does not
    // widen it - it hangs out of the table and the box's overflow-x cuts it in
    // half. It reached production looking like that. These two facts are only a
    // bug TOGETHER, so both are pinned together: if the fixed layout or the 40px
    // pin ever goes, this check should be revisited rather than deleted.
    check('the skills table is still fixed-layout with a pinned last column',
      /\.skill-table \{ table-layout: fixed/.test(css)
      && /\.skill-table th\.num:last-child, \.skill-table td\.num:last-child \{ width: 40px; \}/.test(css),
      'the assumption behind the play-mode column width changed');
    check('so play mode widens it to fit the control',
      /body\.play-mode \.skill-table th\.num:last-child,[\s\S]{0,90}?td\.num:last-child \{ width: 92px; \}/.test(css),
      'the roll control will be clipped by the pinned 40px column again');
  }
  section('Trackable resources');
  {
    const layout = readFileSync(join(appDir, 'js', 'sheet-layout.js'), 'utf8');
    const sheet = readFileSync(appPath('sheet.js'), 'utf8');
    const fmDoc = readFileSync(join(repoRoot, '.claude', 'skills', 'class-import',
      'reference', 'frontmatter.md'), 'utf8');

    // The frontmatter parser already carried a list of maps; nothing about it
    // needed changing, which is most of why this shape was chosen.
    const md = [
      '---', 'id: probe-tr', 'name: Probe', 'system: rifts',
      'source_book: Test', 'category: occ',
      'trackable_resources:',
      '  - key: uppers',
      '    label: Juicer Uppers',
      '    max: 3',
      '    reset_on: day',
      '---', '', '## Lore', 'x', '',
    ].join('\n');
    const parsed = parseClassMarkdown(md);
    check('a class may declare trackable resources in frontmatter',
      parsed.ok && Array.isArray(parsed.data.trackable_resources),
      `errors: ${parsed.errors.join('; ')}`);
    check('and the values keep their types',
      parsed.data?.trackable_resources?.[0]?.max === 3,
      'max came back as something other than the number 3');
    check('declaring one is not a validation error',
      parsed.errors.length === 0 && parsed.warnings.length === 0,
      `errors: ${parsed.errors.join('; ')} warnings: ${parsed.warnings.join('; ')}`);

    // The renderer lives with the other markup helpers, not in the data file.
    check('the renderer is in the presentation module',
      /const trackableRows = /.test(layout), 'trackableRows is not in sheet-layout.js');
    check('and sheet.js does not define its own',
      !/const trackableRows = /.test(sheet), 'trackableRows has drifted into sheet.js');

    // THE DEFAULT IS NOTHING. Every class in the catalogue is in this state.
    // The argument is deliberately loose - it went from `cls.trackable_resources`
    // to a resolved copy of it and the guard is what this pins, not the
    // expression feeding it.
    check('a class that declares none gets no box',
      /const rows = trackableRows\([^;]*cls\.trackable_resources[^;]*\);[\s\S]{0,200}?rows \? box\(/.test(sheet),
      'the box renders even when the class declares nothing');

    // ---- max_formula resolution -------------------------------------------
    // A formula that cannot vary becomes a number; one with a die in it does
    // NOT, because a resource has nowhere to store a roll and re-rolling on
    // every render would move the character's capacity.
    check('an attribute expression resolves to a number',
      fixedFormulaValue('PE', { PE: 14 }) === 14,
      `PE with P.E. 14 came back as ${fixedFormulaValue('PE', { PE: 14 })}`);
    check('and so does one the book multiplies',
      fixedFormulaValue('P.E. x 2', { PE: 14 }) === 28,
      `got ${fixedFormulaValue('P.E. x 2', { PE: 14 })}`);
    check('a plain number resolves to itself',
      fixedFormulaValue('3', {}) === 3);
    check('ANYTHING WITH A DIE IN IT DOES NOT RESOLVE',
      fixedFormulaValue('1D4+ME', { ME: 12 }) === null
      && fixedFormulaValue('2d6', {}) === null,
      'a dice formula resolved, so the max moves on every render');
    check('an unreadable formula does not resolve either',
      fixedFormulaValue('whatever the GM says', {}) === null);
    check('an attribute the character does not have does not resolve',
      fixedFormulaValue('PE', {}) === null,
      'resolved a formula against an absent attribute');

    // The resolution happens in sheet.js, because sheet-layout.js reads no
    // character state and passing the character in would end that. The `(` is
    // load-bearing: sheet-layout.js NAMES fixedFormulaValue in the comment that
    // explains why it does not evaluate formulas, so a bare name match fails on
    // the documentation of the very property it is checking.
    check('sheet.js resolves the formula, not the markup helper',
      /function resolvedResources\(/.test(sheet)
      && !/fixedFormulaValue\(/.test(layout),
      'formula resolution has drifted into sheet-layout.js');
    check('and dice.js exposes it to the classic scripts',
      /globalThis\.diceRoll = \{[^}]*fixedFormulaValue/.test(
        readFileSync(join(appDir, 'js', 'dice.js'), 'utf8')),
      'sheet.js is a classic script and cannot import the module directly');

    check('the box has a stable hook and a column',
      /resources: 'a',/.test(layout), 'the resources box has no column and will flow anywhere');

    // Documented where classes are authored, which is the class-import skill.
    check('the key is documented for the people who write classes',
      /^## Trackable resources/m.test(fmDoc), 'frontmatter.md does not mention it');
    check('omitted and empty are distinguished in the docs',
      /Omitted and empty are different/.test(fmDoc),
      'nothing says what an empty list means');
    // The stock example is not in any imported Juicer, and this is the repo that
    // has a reconciliation pass specifically to stop remembered numbers landing
    // in the catalogue.
    check('and the docs warn against filling it from memory',
      /comes from the book/i.test(fmDoc) && /uppers/i.test(fmDoc),
      'nothing warns that the famous example is not in the imported text');
  }

  // ---------- The session log ----------
  // What the sheet recorded, beside the journal, which is what a person wrote.
  // Two separate boxes because they are two kinds of thing: one is a machine's
  // account and cannot be edited, the other is prose and can.
  section('The session log');
  {
    const sheet = readFileSync(appPath('sheet.js'), 'utf8');
    const layout = readFileSync(join(appDir, 'js', 'sheet-layout.js'), 'utf8');
    const css = readFileSync(join(appDir, 'styles.css'), 'utf8');

    check('the sheet has a session log box',
      /box\('Session log'/.test(sheet), 'the session log box is gone');
    check('and it sits in the prose column beside the journal',
      /'session-log': 'c',/.test(layout), 'the session log has no column');

    // LAZY. The sheet already makes four requests before it can draw, and the log
    // is the one thing most sessions never open. Paying for it every time to
    // serve the times it is wanted is the wrong way round.
    check('it loads on first open, not at render',
      /<details[^>]*id="log-details"[^>]*ontoggle="loadLog\(\)"/.test(sheet),
      'the log is not wired to open lazily');
    check('and render() does not fetch events',
      !/function render\(\)[\s\S]*?events\?limit[\s\S]*?^}/m.test(sheet),
      'the sheet fetches the event log at render');
    check('it fetches once, not on every open',
      /logLoaded = true;/.test(sheet), 'nothing stops a re-fetch on each toggle');
    check('but a failed load stays retryable',
      /logLoaded = false;[\s\S]{0,200}?Could not load/.test(sheet),
      'a failed load leaves the box permanently empty');

    // An undone event is part of the account, not removed from it.
    check('an undone event is shown struck through rather than hidden',
      /log-row\.undone \.log-note \{ text-decoration: line-through/.test(css)
      && /e\.undone_at \? ' undone' : ''/.test(sheet),
      'undone events vanish from the log');

    // Phase 7 asked for this and could not add it: the class did not exist yet.
    const print = printCss(css);
    check('a machine-written log does not print',
      /\.box\[data-box="session-log"\] \{ display: none !important; \}/.test(print),
      'the event log prints on the character sheet');
  }

  // ---------- Two people, one character ----------
  // PATCH used to be `UPDATE characters SET ... WHERE id = ?` with no version
  // check: a player and a G.M. at the same table, or one person in two tabs,
  // overwrote each other silently with last write winning. The draft had the
  // same problem and already solved it; this is the same guard.
  section('Two people, one character');
  {
    const src = readFileSync(join(repoRoot, 'functions', 'api', 'character-creator',
      'characters', '[id].js'), 'utf8');
    const sheet = readFileSync(appPath('sheet.js'), 'utf8');

    check('a caller may say which version it is changing',
      /body\.expect_updated_at/.test(src), 'the PATCH takes no expected version');

    // Guarded IN THE WHERE. Reading the row and then writing leaves exactly the
    // gap this exists to close.
    check('the guard is in the WHERE, not a read followed by a write',
      /AND updated_at = \?/.test(src), 'the version check is not part of the statement');
    check('and it only applies when a version was claimed',
      /\$\{expected \? ' AND updated_at = \?' : ''\}/.test(src),
      'every existing caller breaks, or none of them is guarded');

    check('a refused write says so, and says what is there now',
      /conflict: true,/.test(src) && /current_updated_at/.test(src),
      'a conflict cannot be told apart from a failure');
    check('a missing character is a 404, not a conflict',
      /if \(!current\) return json\(\{ error: 'Character not found' \}, 404\);/.test(src),
      'a deleted character reports as an edit conflict');
    check('a successful write returns the new version',
      /return json\(\{ ok: true, updated_at:/.test(src),
      'a caller must re-read the character to make a second guarded write');

    // The sheet's autosave is the write most likely to clobber someone: it runs
    // unasked, every time a field is left alone for a moment (UI-AUDIT F38).
    // These pinned the Save button's shape until F38 removed it; they pin the
    // INTENT now - version sent, typing never reloaded over, choice offered.
    check('the sheet sends the version it loaded',
      /expect_updated_at: C\.data\.updated_at/.test(sheet),
      'autosave overwrites blindly');
    check('and asks before throwing away what is on screen',
      /err\.status === 409 && err\.detail\?\.conflict/.test(sheet)
        && /Keep mine/.test(sheet) && /Use theirs/.test(sheet),
      'a conflict either reloads over the typing or reports as a generic failure');
    // Every play event moves updated_at and the sheet never learns the new value
    // from one, so a guard judged on the version alone refuses the tab's own
    // saves after any damage. Judged per field against what editing began from.
    check('and a refusal caused only by its own tab retries instead of asking',
      /keys\.filter\(\(k\) => !sameValue\(fresh\[k\], AS\.base\[k\]\)\)/.test(sheet),
      'every pool change in play mode makes the next autosave a false conflict');
  }

  // ---------- Board & Tissue's two component rules ----------
  // The palette and the faces landed first and are measured elsewhere (the F55
  // section in smoke.mjs runs over both live palettes). These are the two
  // rules the WORLD rests on, and both are the kind of thing a later tidy
  // removes without noticing what it was for.
  section('Board & Tissue: the chip column and the mark');
  {
    const css = readFileSync(join(appDir, 'styles.css'), 'utf8');
    const sheet = readFileSync(appPath('sheet.js'), 'utf8');

    // A ::before rather than a border-left, and the difference is not
    // cosmetic: a border-left REPLACES one of the box's four sides, which is
    // what turns a block into a callout. The chip sits behind the whole block
    // with all four borders still drawn.
    check('the chip is a column of board, not a border',
      /\.box::before \{[\s\S]{0,200}?width: 13px;/.test(css)
      && !/^\.box \{[^}]*border-left:/m.test(css),
      'the chip column is gone, or became a border-left');
    check('and its padding makes room for it',
      /^\.box \{[^}]*padding-left: 13px;/m.test(css));

    // data-col already ranked the boxes; the chip is the third thing that rank
    // buys. If someone re-points these at status colours the hue table in the
    // :root block stops being true, so the mapping is pinned by name.
    const chips = ['a', 'b', 'c']
      .filter((c) => new RegExp(`\\.box\\[data-col="${c}"\\] \\{ --chip:`).test(css));
    check('every column rank carries its own chip', chips.length === 3, 'have: ' + chips.join(', '));
    check('and the identity block takes the accent, being the document’s subject',
      /\.box\.identity \{ --chip: var\(--accent\); \}/.test(css));

    // Furniture does not print; state does. Both halves asserted, because
    // suppressing the wrong one is the easy mistake.
    check('the chip does not reach paper',
      /@media print \{[\s\S]{0,900}?\.box::before \{ display: none; \}/.test(css),
      '13px of ink down every block on a three-page sheet');

    // THE MARK REPLACES AN OPACITY, which is the whole point of it. If the
    // class stops being emitted the rows silently go back to being told apart
    // by a 0.45 dim on the button alone.
    check('a power out of reach is marked, not merely dimmed',
      /\.power-row\.short::before \{/.test(css)
      && /\.power-row\.short > span:first-child \{[\s\S]{0,140}?text-decoration: line-through;/.test(css));
    check('the row grid made a cell for the mark',
      /\.power-row \{[\s\S]{0,160}?grid-template-columns: 10px 1fr auto auto;/.test(css),
      'the mark has no column, so it is sharing one with the name');
    check('and the sheet emits the class on the same condition usePower guards on',
      /const short = cost != null && left != null && left < cost;/.test(sheet)
      && /class="power-row\$\{short \? ' short' : ''\}"/.test(sheet),
      'the mark and the disabled button could now disagree');
    check('the shortfall says how much, which the dim never could',
      /class="short-by">short \$\{cost - left\}/.test(sheet));
    // Not gated on write access: a read-only sheet still answers "can she cast
    // this", and that is most of what the question is for.
    check('and it is not gated on write access',
      !/const short = w &&/.test(sheet));

    // A LONG POOL SHRINKS RATHER THAN CLIPS. Four digits overflowed the input
    // that clips them at every card width the grid can produce - before the
    // figure face as well as after it.
    const layout = readFileSync(join(appDir, 'js', 'sheet-layout.js'), 'utf8');
    check('the pool value takes its size from a property, not a literal',
      /\.vital \.val \{ font-size: var\(--val-size, 44px\);/.test(css),
      'the 44px is hard-coded again, so a long value has nothing to shrink to');
    check('and four and five digits each have one',
      /\.vital\[data-digits="4"\] \{ --val-size: 32px; \}/.test(css)
      && /\.vital\[data-digits="5"\] \{ --val-size: 26px; \}/.test(css));

    // THE SPECIFICITY IS THE POINT. Sized on .vital and read by .val, the two
    // font-size declarations tie at (0,2,0) and the print block wins on source
    // order. A `.vital[data-digits] .val` selector would be (0,3,0) and would
    // print a 32px number on a 10pt sheet - silently, because the print check
    // greps for a string that would still be sitting there.
    check('the size is set on the card, so the print rule still outranks it',
      !/\.vital\[data-digits="[45]"\] \.val \{/.test(css),
      'a (0,3,0) selector would beat the print rule');

    // It has to move WITH the value. paintPool is where a stepper, a damage
    // press and a queued change all land, so a pool crossing 999 either way
    // would otherwise keep whatever size it was first drawn at.
    check('the digit count is emitted on render',
      /data-digits="\$\{Math\.min\(digits, 5\)\}"/.test(layout));
    check('and repainted when the value changes, in both directions',
      /card\.setAttribute\('data-digits'/.test(layout)
      && /card\.removeAttribute\('data-digits'\)/.test(layout),
      'a pool dropping back under 1000 would keep the smaller size');
  }

  // ---------- The front door agrees with the rooms ----------
  // index.html does not load /shared/styles.css (nor does Marvel Heroes, which is
  // its own visual system) - it is deliberately self-contained - so it carries its own copy of the palette under
  // its own names. That copy drifted for the whole of the Rust & Ash redesign:
  // every app behind it was retoned in phase 1 and the landing page stayed blue
  // and violet until it was done deliberately, months of commits later.
  //
  // A comment already told it to keep in step and did not stop that happening.
  // This compares the values.
  //
  // It lives in this suite because no suite owns repo-root files and this is the
  // one that already reaches outside its own app.
  section('The front door agrees with the rooms');
  {
    const landing = readFileSync(join(repoRoot, 'index.html'), 'utf8');
    // THE ROOMS THIS DOOR OPENS ONTO ARE THE RPG SUITE, and since 2026-09-20
    // that is no longer shared/styles.css. Board & Tissue retoned the five RPG
    // apps through a :root in apps/character-creator/styles.css and left
    // FilamentForge, MediaVault and Pick 3 Cut 5 on shared's Ley Verdigris, so
    // comparing the landing page against shared would now assert that the front
    // door matches the three apps it is deliberately NOT toned like. The hub is
    // orange because the suite is.
    const shared = readFileSync(join(appDir, 'styles.css'), 'utf8');

    // Comments first: the stylesheet records its measured contrast ratios
    // in prose that names the tokens, and a line reading
    // `--bg-primary: --text-primary 14.74, ...` matches a naive search.
    const noComments = (src) => src.replace(/\/\*[\s\S]*?\*\//g, '');
    const declared = (src, name) =>
      (noComments(src).match(new RegExp(`--${name}:\\s*([^;]+);`)) || [])[1]?.trim().toLowerCase();

    // Its names are its own; the values have to match by ROLE.
    const pairs = [
      ['bg', 'bg-primary'], ['bg-card', 'bg-card'], ['border', 'border'],
      ['text', 'text-primary'], ['text-sub', 'text-secondary'],
      ['text-muted', 'text-muted'], ['accent', 'accent'],
      ['accent2', 'accent-secondary'], ['success', 'success'], ['warning', 'warning'],
    ];
    const wrong = pairs.filter(([here, there]) =>
      declared(landing, here) !== declared(shared, there));
    check('every colour on the landing page is the shared one under another name',
      wrong.length === 0,
      wrong.map(([a, b]) =>
        `--${a} is ${declared(landing, a)} where --${b} is ${declared(shared, b)}`).join('; '));

    // The two things phase 1 did to .logo, which this page's h1 had too.
    check('the wordmark is a colour, not a gradient clipped to text',
      !/-webkit-background-clip: text/.test(landing),
      'the hero still paints its heading with a gradient');
    check('and nothing here casts a shadow, because --shadow is none',
      !/box-shadow/.test(landing), 'a card still has a blur under it');

    // The same finding as the wizard's .st.na, on the same kind of element.
    check('the coming-soon card is not dimmed below readable',
      !/\.card-soon \{[^}]*opacity/.test(landing),
      'opacity on that card measured 2.48:1 on its description text');

    // WORKSHOP-UI-AUDIT W2. The cards are drawn icons now, and that rests on
    // ONE deliberate inconsistency: `icon` is the only manifest field the
    // renderer does not pass through esc(). Escaping it would print the markup
    // as text on every card, and nothing else would look wrong — so the
    // omission is asserted here rather than left to a comment. index.html
    // points at this check by name; if it moves, fix that comment too.
    const manifest = JSON.parse(readFileSync(join(repoRoot, 'apps', 'manifest.json'), 'utf8'));
    check('every card icon is drawn markup rather than an emoji glyph',
      manifest.apps.length > 0 && manifest.apps.every((a) => /^<svg\b/.test(a.icon || '')),
      manifest.apps.map((a) => `${a.slug || '(soon)'}=${(a.icon || '').slice(0, 12)}`).join(' '));
    check('and the renderer still does not escape it, which is what makes that work',
      /<div class="card-icon">\$\{app\.icon\}<\/div>/.test(landing),
      'esc() around app.icon would print five cards of SVG source');
    check('while the fields a person types stay escaped',
      /\$\{esc\(app\.name\)\}/.test(landing) && /\$\{esc\(app\.description\)\}/.test(landing),
      'name or description lost its esc()');

    // The hub is sectioned by manifest group since 2026-09-23. An app whose
    // group is misspelt still renders - in the last, catch-all section - so a
    // typo moves a tile and nothing on the page looks broken. This is the
    // only place that notices.
    const groupIds = (manifest.groups || []).map((g) => g.id);
    const ungrouped = manifest.apps.filter((a) => !groupIds.includes(a.group));
    check('every app names a group the manifest declares',
      groupIds.length > 0 && ungrouped.length === 0,
      groupIds.length ? ungrouped.map((a) => `${a.slug || '(soon)'}=${a.group}`).join(' ')
        : 'the manifest has no groups list');
    check('and the section titles are escaped like the other typed fields',
      /\$\{esc\(g\.title\)\}/.test(landing), 'g.title reaches innerHTML unescaped');
  }

  // ---------- Changes that could not be sent ----------
  // A pool change made with no network stays on screen and waits, instead of
  // rolling back. What this is NOT is offline support: nothing here serves the
  // page, so a tab closed without a connection will not open again. The queue
  // survives a drop and a reload with the tab open, and that is the whole claim.
  section('Changes that could not be sent');
  {
    const queue = readFileSync(join(appDir, 'js', 'play-queue.js'), 'utf8');
    const sheet = readFileSync(appPath('sheet.js'), 'utf8');
    const layout = readFileSync(join(appDir, 'js', 'sheet-layout.js'), 'utf8');
    const css = readFileSync(join(appDir, 'styles.css'), 'utf8');
    const html = readFileSync(appPath('sheet.html'), 'utf8');
    const events = readFileSync(join(repoRoot, 'functions', 'api', 'character-creator',
      'characters', '[id]', 'events.js'), 'utf8');

    check('the queue exists and is loaded', /global\.playQueue/.test(queue)
      && html.includes('js/play-queue.js'), 'js/play-queue.js is missing or not loaded');
    check('and the promise it makes is written down, not implied',
      /does not promise/i.test(queue) && /service worker/i.test(queue),
      'nothing says this is not offline support');

    // Order is the contract: two adjustments to one pool only compose if they
    // are replayed in the sequence they were made.
    check('the queue keeps its order',
      /autoIncrement: true/.test(queue), 'the queue has no inherent order');
    check('and the flush replays serially, not in parallel',
      /for \(const e of pending\)/.test(sheet), 'the flush fires everything at once');

    // A REFUSAL AND A SILENCE ARE DIFFERENT THINGS. Counted across EVERY
    // caller rather than matched once: the check used to name one call site,
    // so the Damage button could queue - or not queue - without it noticing.
    // Every queueChange call must sit behind the same `err.status === undefined`
    // test, or something is queueing changes the server refused on merit.
    const queueCalls = sheet.match(/await queueChange\(/g) || [];
    const guardedQueueCalls = sheet.match(/err\.status === undefined && await queueChange\(/g) || [];
    check('every queued write is a silence, never a refusal',
      queueCalls.length > 0 && queueCalls.length === guardedQueueCalls.length,
      `${queueCalls.length} queueChange call(s), ${guardedQueueCalls.length} behind the status test`);
    // EVERY play write that changes state, named. The steppers and Damage came
    // first; rest, ammo and a power spend followed, each having lost its change
    // to a dropped connection until it did. Named individually rather than
    // counted, because a count says nothing about WHICH one stopped queueing.
    // A roll is deliberately absent - it carries no state change, and queueing
    // every tap of an offline fight would fill the queue with commentary. It
    // reports its own failures instead.
    for (const kind of ['pool', 'damage', 'ammo', 'power']) {
      check(`a ${kind} change queues`, new RegExp(`await queueChange\\('${kind}'`).test(sheet),
        `nothing queues a '${kind}' change, so a dropped one is lost`);
    }
    check('and rest queues among the pool changes',
      /queueChange\('pool',\s*\n?\s*`rested/.test(sheet),
      'a rest lost to a dropped connection is not recoverable');
    check('a roll is NOT queued', !/await queueChange\('roll'/.test(sheet),
      'rolls queue now - deliberate? they carry no change and can flood the queue');
    check('and a browser with no IndexedDB falls back to rolling back',
      /if \(!window\.playQueue \|\| !\(await playQueue\.available\(\)\)\) return false;/.test(sheet),
      'a private window loses the change with no rollback');

    // The trap this repo has been bitten by before: Access answers with HTML, and
    // api() returns {} for a body it cannot parse, so a replay after the session
    // expires looks exactly like success.
    check('a replay that lands on the login page is not counted as sent',
      /res\.event_id == null/.test(sheet),
      'an expired Access session silently eats the queue');

    // Guarded replay, per field.
    check('the server can be asked to check where the pool was',
      /if \(b\.guard\)/.test(events), 'events.js ignores `from` as it always did');
    check('and it checks each pool, not the row',
      /guards\.push\(`\$\{field\} IS \?`\)/.test(events),
      'two people touching different pools are called a conflict');
    check('a clash reports both sides',
      /mine: charFields\[f\]\.to, theirs: current\[f\]/.test(events),
      'the client cannot offer a choice because it is only told one number');
    check('and nothing is logged for a change that did not apply',
      events.indexOf('conflict: true') < events.indexOf('await env.DB.batch(statements)'),
      'a refused replay still writes a play event');

    // The cell keeps its size and nothing else is blocked.
    check('the conflict splits the value in two',
      /function conflictMarkup/.test(layout) && /cf-half/.test(css),
      'there is no conflict UI');
    check('each side is a finger-sized target',
      /\.vital \.cf-half \{[\s\S]*?min-height: 44px;/.test(css), 'the halves are mouse-sized');
    check('and the stale number is hidden in BOTH modes',
      /body\.play-mode \.vital\.conflict \.val > b,/.test(css),
      'play mode reveals the <b> at higher specificity, so the cell shows three figures');

    check('the flush runs when the network returns',
      /addEventListener\('online'/.test(sheet), 'a reconnect does not flush');

    // ONE PRESS, ONE ENTRY, ONE EVENT. A Damage that spills out of S.D.C. into
    // H.P. moves two pools, and the queue has to carry them together: split
    // into two entries it would put two rows in the log, let undo take back
    // half a hit, and make the session recap count one blow as two. So the
    // entry carries a FIELD MAP, and the replay sends it whole.
    // LOOSER THAN IT WAS, on purpose. These three pinned the exact call text,
    // and all three broke the day ammo learned to queue - the shape changed
    // and the BEHAVIOUR did not, which is a false alarm and the precise
    // weakness this section has. play-flow.mjs asserts the behaviour by running
    // it; what is worth pinning here is only that the field map and the item
    // change reach the queue and the replay at all.
    check('an entry carries every field of its press',
      /playQueue\.push\(\{[^}]*\bfields\b[^}]*\}\)/.test(sheet),
      'the queue stores one field per entry, so a two-pool press is split');
    check('and an item change rides beside them',
      /playQueue\.push\(\{[^}]*\bitem\b[^}]*\}\)/.test(sheet),
      'an ammo write cannot be queued, because an entry cannot carry one');
    check('and the replay sends them in one event',
      /character: entryFields\(e\)/.test(sheet),
      'the replay rebuilds a single-field change and drops the rest of the press');
    check('and the replay keeps the press\'s own kind',
      /kind: e\.kind \|\| 'pool'/.test(sheet),
      "a queued Damage replays as something other than a 'damage' event");

    // IndexedDB OUTLIVES A DEPLOY. A player who queued a change before the
    // field map shipped has a one-field row waiting, and the flush has to
    // replay it rather than dropping it or throwing on a missing `fields`.
    check('an entry queued in the older shape still replays',
      /if \(e\.key\) return \{ \[e\.key \+ '_current'\]/.test(sheet),
      'a change queued before the field map shipped is lost on flush');

    // Half an answered Damage is exactly the split the queue exists to avoid.
    check('a press that clashed on two pools waits for both answers',
      /Object\.values\(C\.conflicts\)\.some\(\(x\) => x\.seq === c\.seq\)/.test(sheet),
      'answering one pool sends the press with the other still unanswered');
    check('and an answered pool stops offering the choice',
      /delete C\.conflicts\[key\];[\s\S]{0,300}?C\.resolved\[c\.seq\]/.test(sheet),
      'an answered card keeps showing two halves, or the answer is lost');
  }

  // ---------- The sheet reads item_* fields the endpoint actually sends ----------
  // WRITTEN FROM A LIVE BUG. sheet.js tested `it.item_id` in two places - the
  // catalog/custom tag on every inventory row, and isWeapon(), which decides
  // whether a held item becomes a play-mode weapon card. Migration 046 dropped
  // `character_items.item_id` (RETRO-AUDIT R21) and the GET selects
  // `character_items.*` plus a set of `item_*` ALIASES, none of them `item_id`.
  // So the test was `undefined &&` for every row from that day on: every item
  // read as "custom", and no held weapon ever produced a card.
  //
  // Nothing failed and nothing looked wrong, which is the shape a rename leaves
  // behind. This derives the alias list from the endpoint rather than pinning a
  // list here, so it keeps working when the projection changes - the failure it
  // exists to catch is precisely somebody changing one side only.
  section('The sheet reads only item fields its endpoint sends');
  {
    const idJs = readFileSync(
      join(appDir, '..', '..', 'functions', 'api', 'character-creator', 'characters', '[id].js'), 'utf8');
    const aliased = new Set([...idJs.matchAll(/AS\s+(item_[a-z_]+)/gi)].map((m) => m[1]));
    // `character_items.*` is in the same SELECT, so the stored columns travel
    // under their own names too. None of those is `item_`-prefixed, so nothing
    // here collides with them.
    //
    // COMMENTS ARE STRIPPED FIRST, and that is not fussiness: the fix for the
    // bug this check exists for carries a comment SAYING `it.item_id`, and
    // scanning raw text failed on the prose explaining the fix. A check that
    // cannot tell code from the note about the code is worse than none.
    const code = readFileSync(appPath('sheet.js'), 'utf8')
      .replace(/\/\*[\s\S]*?\*\//g, ' ')
      .replace(/^\s*\/\/.*$/gm, ' ');
    const read = new Set([...code.matchAll(/\bit(?:em)?\.(item_[a-z_]+)/g)].map((m) => m[1]));
    const phantom = [...read].filter((f) => !aliased.has(f));
    check('every item_* field the sheet reads is one the endpoint aliases',
      phantom.length === 0,
      `sheet.js reads ${phantom.join(', ')} - the GET sends ${[...aliased].join(', ')}`);
    check('and the endpoint sends the stat block, not just a name',
      ['item_damage', 'item_range', 'item_mdc', 'item_description'].every((f) => aliased.has(f)),
      [...aliased].join(', '));
  }

  // ---------- The codex ----------
  // Plan 20's second half, widened: every spell, power, item and vessel with
  // its text, for the ones a character does NOT hold. A seventh page, read-only
  // by construction.
  section('The codex');
  {
    const html = readFileSync(appPath('codex.html'), 'utf8');
    const js = readFileSync(appPath('codex.js'), 'utf8');
    const css = readFileSync(join(appDir, 'styles.css'), 'utf8');
    const sheetHtml = readFileSync(appPath('sheet.html'), 'utf8');
    const wizardHtml = readFileSync(join(appDir, 'index.html'), 'utf8');
    const sheet = readFileSync(appPath('sheet.js'), 'utf8');

    check('the page exists and loads its script',
      /src="codex\.js"/.test(html) && /js\/api\.js/.test(html), 'codex.html does not load codex.js');

    // Read-only is the security posture AND the reason it can be a player page
    // at all: there is no write path to get wrong. Asserted against the file
    // rather than trusted, because adding one would be a one-line change.
    check('it is read-only by construction',
      !/method:\s*'(POST|PATCH|PUT|DELETE)'/i.test(js) && !/jsonReq\(/.test(js),
      'codex.js has grown a write path; it is served to every authenticated player');
    check('and it asks for its own route, not the boot payload',
      /api\('codex\?section=/.test(js) && !/api\('catalogs'\)/.test(js),
      'the codex is loading /catalogs, which is the payload plan 20 kept it out of');
    // A SECTION, not the whole route. The bare `/codex` used to serve spells
    // and psionics together; gear and vessels made that a 261 KB fetch before
    // the page paints, against a 25 KB boot payload, so each catalog is asked
    // for when its tab is first opened. A page that reverted to one fetch would
    // still pass the check above.
    check('and it fetches one section at a time, not the whole codex',
      !/api\('codex'\)/.test(js) && /section=' \+ encodeURIComponent/.test(js),
      'codex.js is asking for the whole codex in one request again');
    // Plan 22 D1. Super abilities are 323 KB gzipped with their text, so the
    // list travels without it and ONE entry's is fetched when its row opens.
    // regression.mjs holds the endpoint to that; this holds the page to asking
    // by name, ENCODED - 16 of the 364 names carry an ampersand (production,
    // 2026-09-17), and an unencoded one asks for "Generate Fog " and gets a 404
    // that reads like missing data.
    // A link to ONE entry (#spells/<key>): the sheet builds these, so the
    // encoding and the lower-casing are a contract between two files, not a
    // detail of one. 378 spell names carry a colon and some an apostrophe;
    // an unencoded or case-sensitive key is a link that lands on nothing.
    check('a link can name one entry, encoded and matched case-insensitively',
      /function entryHash\(secId, key\)[\s\S]{0,120}encodeURIComponent\(key\)/.test(js)
        && /decodeURIComponent\([^)]*\)\)\.toLowerCase\(\)/.test(js)
        && /addEventListener\('hashchange', applyHash\)/.test(js),
      'codex.js no longer opens #<section>/<key> links the sheet relies on');
    check('and a link to an entry that is not there says so',
      /S\.missing = want\.slice/.test(js) && /has no entry by that name/.test(js),
      'a broken entry link would land on the top of the list as if it had worked');
    // Sort and group (plan PR 4). The group menu is each section's own META
    // line, so a new section inherits it; the sort keeps missing numbers LAST
    // in either order, since "no price" is not the cheapest item; and the
    // whole narrowing rides in the query string, so a filtered view is a link.
    check('the list can be narrowed to one group and sorted, and says so in its address',
      /if \(group && sec\.meta\(r\) !== group\) return false/.test(js)
        && /return sortRows\(sec, rows\)/.test(js)
        && /x == null \? 1 : -1/.test(js)
        && /new URLSearchParams\(location\.search\)/.test(js)
        && /history\.replaceState\(null, '', location\.pathname \+ \(qs \?/.test(js),
      'codex.js lost its group filter, its sort, or the query string that makes a filtered view a link');
    // A class entry starts a character (plan PR 5). The codex half is a LINK
    // so the page stays read-only; the wizard half must take the class off the
    // address (or a reload starts a second build) and must NOT start over a
    // draft without asking - one draft per person, and a link followed from a
    // reference page is the last thing that should discard a rolled character.
    {
      const wizard = readFileSync(join(appDir, 'app.js'), 'utf8');
      check('a class entry links to the wizard with that class',
        /\/apps\/character-creator\/\?class=\$\{\s*encodeURIComponent\(r\.slug\)\}/.test(js),
        'the codex class entry lost its way into the wizard');
      check('and the wizard takes it, asking first when a draft is waiting',
        /new URLSearchParams\(location\.search\)\.get\('class'\)/.test(wizard)
          && /history\.replaceState\(null, '', location\.pathname \+ location\.hash\)/.test(wizard)
          && /else if \(S\.draftOffer\) S\.classOffer = c;\s*else \{ startWithClass\(c\); return; \}/.test(wizard),
        'the wizard ignores ?class=, keeps it in the address, or starts over a draft without asking');
    }
    // "Your characters with this" (plan PR 9). One read for the whole page,
    // and a route that cannot be widened: it binds the caller's email and
    // reads NOTHING from the request. regression.mjs asks as a second person;
    // this holds the shape that makes that answer true for every request.
    {
      const holdings = readFileSync(join(repoRoot, 'functions', 'api', 'character-creator', 'me', 'holdings.js'), 'utf8');
      check('the codex asks once which of the reader\'s own characters hold what',
        /api\('me\/holdings'\)/.test(js) && (js.match(/me\/holdings'/g) || []).length === 1
          && /function heldBy\(sec, r\)/.test(js),
        'the codex lost its holdings read, or asks for it more than once');
      check('and that route reads nothing from the request but who is asking',
        !/searchParams|new URL\(request|readJson|params\./.test(holdings)
          && (holdings.match(/player_email = \? AND c\.kind = 'pc'/g) || []).length === 1
          && /\.bind\(email\)/.test(holdings) && !/\.bind\((?!email\))/.test(holdings),
        'me/holdings can be steered by the request, or binds something other than the caller');
    }
    check('and a link to one entry clears whatever narrowing would hide it',
      /S\.system = '';\s*S\.filter = '';\s*S\.group = '';/.test(js),
      'an entry link can land under a filter that hides the entry it names');
    check('and a super ability\'s text is asked for one entry at a time, its name encoded',
      /'codex\?section=super-ability&name=' \+ encodeURIComponent\(r\.name\)/.test(js),
      'codex.js no longer fetches a super ability by encoded name');

    // THE TRAP: .tabbar is display:none above 820px, because the SHEET's tabs
    // are a narrow-screen affordance. Reusing the class without this rule makes
    // the codex's tabs vanish on a desktop, which is where you browse a codex.
    check('its tabs survive at desktop width',
      /\.tabbar\.codex-tabs \{ display: flex; \}/.test(css),
      '.tabbar is display:none above 820px and the codex would show no tabs there');

    // Plan 22. `.tabbar` wraps only under 620px, and seven tabs need 759px: at
    // a 768px tablet the strip is 706, so the last tab sat behind a horizontal
    // scrollbar. Measured in a browser 2026-09-17; this only pins the rule that
    // fixed it, and a text check cannot tell you the bar still fits - look.
    check('and wrap at every width, so a tablet cannot scroll one out of sight',
      /\.tabbar\.codex-tabs \{ flex-wrap: wrap; \}/.test(css),
      'above 620px the codex tab bar scrolls sideways again and hides its last tab');

    // Same lesson as .power-toggle on the sheet: the shared print block hides
    // every button, and the codex row IS a button. A codex is a reference
    // document, so unlike the sheet it prints its prose.
    check('and its rows print, being a reference document',
      /\.codex-head \{ display: grid !important;/.test(css),
      'the blanket button rule leaves the printed codex as stat blocks with no names');

    check('the sheet points at it from the powers tab',
      /\/apps\/codex\//.test(sheet), 'nothing on the sheet mentions the codex');
    // And from each thing it holds, to that thing's own entry. The key rule is
    // the codex's (encoded, lower-cased); a sheet that built it differently
    // would link every spell with a capital letter to "no entry by that name".
    check('and each held skill, power, item and vessel links to its own entry',
      /encodeURIComponent\(String\(key\)\.toLowerCase\(\)\)/.test(sheet)
        && /codexLink\('skills', s\.name/.test(sheet)
        && /codexLink\(POWER_SECTION\[kind\], p\.name/.test(sheet)
        && /codexLink\('gear', it\.item_slug/.test(sheet)
        && /codexLink\('vehicles', v\.vehicle_slug/.test(sheet),
      'a row on the sheet has lost its link into the codex');
    // Every power kind the sheet files must name a codex section, or its
    // link silently renders nothing.
    check('and every power kind the sheet sorts has a codex section to link to',
      ['spell', 'psionic', 'super', 'talent'].every((k) =>
        new RegExp(`POWER_SECTION = \\{[^}]*\\b${k}: '`).test(sheet))
        && /const KIND_ORDER = \{ spell: 0, psionic: 1, super: 2, talent: 3 \}/.test(sheet),
      'a power kind has no codex section, or the sheet sorts a kind this check does not know');
    // This pinned a literal `codex.html` anchor in both headers until the app
    // switcher replaced every page's ad-hoc links (shared/js/appnav.js). What
    // the check was ever FOR is that neither page leaves the codex reachable
    // only by typing a URL, so it now asks for the switcher that carries it -
    // the rule, not the markup that used to satisfy it.
    const nav = readFileSync(join(repoRoot, 'shared', 'js', 'appnav.js'), 'utf8');
    check('and both pages carry the switcher that reaches it',
      /data-appnav/.test(sheetHtml) && /data-appnav/.test(wizardHtml)
        && /appnav\.js/.test(sheetHtml) && /appnav\.js/.test(wizardHtml)
        && /codex: '\/apps\/codex\/'/.test(nav),
      'the codex is reachable only by typing the URL');
  }

  // ---------- One header for five apps ----------
  // The character creator is five jobs - build, play, look up, keep notes, run
  // a table - and every page navigated with its own ad-hoc `home-link` list
  // naming whatever that page happened to need. The sheet offered codex and
  // creator, the dashboard offered neither, and nothing named the five at all.
  // shared/js/appnav.js is the one header they share; P1 of the split, before
  // any URL moves.
  section('One header for five apps');
  {
    const navSrc = readFileSync(join(repoRoot, 'shared', 'js', 'appnav.js'), 'utf8');
    const sharedCss = readFileSync(join(repoRoot, 'shared', 'styles.css'), 'utf8');
    const PAGES = ['index.html', 'sheet.html', 'codex.html', 'campaign.html',
                   'dashboard.html', 'catalog.html'];
    const pages = Object.fromEntries(PAGES.map((p) => [p, readFileSync(appPath(p), 'utf8')]));

    // A page that loads the script without the mount renders no header at all,
    // and a mount without the script renders an empty box - so both, per page.
    const missing = PAGES.filter((p) => !/data-appnav/.test(pages[p]) || !/shared\/js\/appnav\.js/.test(pages[p]));
    check('every page mounts the shared header and loads it', missing.length === 0, missing.join(', '));

    // The mount names which app it is, and the names are the five agreed with
    // Nate: Creator, Play, Codex, Campaign, GM Tools. catalog.html is Codex's
    // admin face and marks Codex, deliberately.
    const marked = Object.fromEntries(PAGES.map((p) =>
      [p, (/data-app="([a-z]+)"/.exec(pages[p]) || [])[1]]));
    check('and says which of the five it is',
      marked['index.html'] === 'creator' && marked['sheet.html'] === 'play'
      && marked['codex.html'] === 'codex' && marked['catalog.html'] === 'codex'
      && marked['campaign.html'] === 'campaign' && marked['dashboard.html'] === 'gm',
      JSON.stringify(marked));
    for (const id of ['creator', 'play', 'codex', 'campaign', 'gm', 'city']) {
      check(`the switcher offers ${id}`, new RegExp(`id: '${id}'`).test(navSrc));
    }

    // The ad-hoc links are GONE rather than left beside the switcher: two
    // mechanisms for one job is how the sheet ended up with a hand-built
    // 'campaign' anchor nothing else knew about.
    const leftovers = PAGES.filter((p) => /class="home-link"/.test(pages[p]));
    check('and no page keeps its own ad-hoc link list', leftovers.length === 0, leftovers.join(', '));

    // The sheet prints. Its own `noprint` convention covers what that page
    // drew; the shared header is not that page's, so it hides itself.
    check('the header hides itself on paper',
      /@media print \{ \.appnav \{ display: none; \} \}/.test(sharedCss));

    // A menu button, not a <details> - the same answer W3 reached for the bulk
    // bar - and a disabled destination rather than a vanishing one.
    check('the switcher is a menu button with a real expanded state',
      /aria-expanded="false"/.test(navSrc) && /aria-haspopup/.test(navSrc)
      && !/<details/.test(navSrc));
    // Play opens the roster when no character is named, so no entry is dead.
    // This asked for a DISABLED Play for one day, which was the honest answer
    // while the sheet had no landing of its own; the roster moved there on
    // 2026-09-19 and the entry stopped needing an excuse. The disabled state
    // itself stays in the module for the next entry that earns it.
    check('no switcher entry is a dead end',
      !/href: null/.test(navSrc) && /is-disabled/.test(navSrc));
    check('and Play with no character opens the roster',
      /play: '\/apps\/character-sheet\/'/.test(navSrc) && /: APP\.play,/.test(navSrc));
    const sheetSrc = readFileSync(appPath('sheet.js'), 'utf8');
    check('which the sheet draws instead of refusing',
      /if \(!id\) \{\s*roster\(\);/.test(sheetSrc)
      && /characters\?mine=1/.test(sheetSrc) && /classes\?names=1/.test(sheetSrc));
    // A character that does not load must not keep its name - or its id - in
    // the header. Seen on production: ?id=1 named no character there, the chip
    // read "Character 1" from the URL alone, and carried that into GM Tools.
    const failedAt = sheetSrc.indexOf('Failed to load');
    const clearedAt = sheetSrc.indexOf("appnav?.clear('character')");
    check('and a sheet that fails to load stops naming that character',
      failedAt > 0 && clearedAt > failedAt && (clearedAt - failedAt) < 900,
      'the chip keeps a character the sheet could not open');
    // And the Creator stops being the place you go to do everything except
    // create: its home view no longer draws either list.
    const wizSrc = readFileSync(join(appDir, 'app.js'), 'utf8');
    check('the Creator keeps building and hands the lists over',
      /<h2>Start a character<\/h2>/.test(wizSrc)
      && !/<h2>Your characters<\/h2>/.test(wizSrc)
      && !/<h2>Your campaigns<\/h2>/.test(wizSrc));

    // ── five apps, five URLs, and the old ones still work ──
    // The pages moved out on 2026-09-19. Three things have to hold together or
    // the split is half done: the app exists, the hub offers it, and the path
    // it used to live at still takes a bookmark somewhere useful.
    const manifest = JSON.parse(readFileSync(join(repoRoot, 'apps', 'manifest.json'), 'utf8'));
    const tiles = Object.fromEntries(manifest.apps.filter((a) => a.slug).map((a) => [a.slug, a]));
    // Six since 2026-09-23: the City Creator joined the suite, and loads the
    // shared header and the Board & Tissue sheets like the five.
    for (const slug of ['character-creator', 'character-sheet', 'codex', 'campaign', 'gm-tools', 'city-creator']) {
      const index = join(repoRoot, 'apps', slug, 'index.html');
      check(`${slug} is an app with its own page`,
        existsSync(index) && /data-appnav/.test(readFileSync(index, 'utf8')));
      check(`and the hub offers it`,
        tiles[slug]?.status === 'live' && /^<svg /.test(tiles[slug]?.icon || ''),
        slug + ' has no live tile with an icon');
    }
    // A stub that drops the query string loses the character or the campaign,
    // which is the whole of what those URLs carry.
    for (const [old, to] of [['sheet.html', '/apps/character-sheet/'],
                             ['codex.html', '/apps/codex/'],
                             ['catalog.html', '/apps/codex/catalog.html'],
                             ['campaign.html', '/apps/campaign/'],
                             ['dashboard.html', '/apps/gm-tools/']]) {
      const stub = readFileSync(join(appDir, old), 'utf8');
      check(`${old} still takes a bookmark to ${to}`,
        stub.includes(`location.replace('${to}' + location.search + location.hash)`)
        && stub.includes(`href="${to}"`),
        old + ' no longer forwards, or drops the query string');
    }

    // The URL is the truth. A link sent to a player must open on THAT
    // character, so storage may only fill what the URL leaves unsaid.
    check('the URL wins over the remembered context',
      /params\.get\('id'\)/.test(navSrc) && /params\.get\('campaign_id'\)/.test(navSrc)
      && navSrc.indexOf('readStore()') < navSrc.indexOf("params.get('id')"));
  }

  // ---------- the screen turned round at the table ----------
  //
  // P4b, 2026-09-20. P4a gave the GM pages of pictures and one switch that
  // hands a picture to the players for good. It had no answer for the
  // commonest thing that happens at a table - turning the laptop round so the
  // party can LOOK at a map that stays the GM's - so a GM wanting to do that
  // had to reveal it, which is a different and permanent decision.
  //
  // SHOWING IS NOT REVEALING is therefore the rule this section exists for.
  // present.html reads the GM's own pictures through the GM-only entry
  // endpoint and writes nothing; one button reveals, and it is the only place
  // in the file a write comes from. That is a rule a comment states and a
  // refactor quietly breaks, which is why it is asserted rather than
  // described - the argument `instructions-do-not-fire-by-themselves` makes.
  section('Present mode shows without revealing');
  {
    const gmDir = join(repoRoot, 'apps', 'gm-tools');
    const presentHtml = readFileSync(join(gmDir, 'present.html'), 'utf8');
    const presentJs = readFileSync(join(gmDir, 'present.js'), 'utf8');
    const dash = readFileSync(appPath('dashboard.js'), 'utf8');
    const css = readFileSync(join(appDir, 'styles.css'), 'utf8');

    // ── the one write, and where it is allowed to come from ──
    const reveal = functionBody(presentJs, 'async function toggleReveal()');
    check('present.js has a toggleReveal to read', !!reveal);
    const patches = (presentJs.match(/method: 'PATCH'/g) || []).length;
    check('and the whole file sends exactly one PATCH', patches === 1, patches + ' of them');
    check('which is inside it', !!reveal && /method: 'PATCH'/.test(reveal));
    const wired = [...presentJs.matchAll(/\$\('(\w+)'\)\.addEventListener\('\w+', toggleReveal\)/g)]
      .map((m) => m[1]);
    check('and one control is wired to it', wired.length === 1 && wired[0] === 'reveal',
      wired.join(', ') || 'nothing calls it');

    // Every arrow, every button and the initial load funnel into show(). A
    // reveal that crept in there would hand the party a picture for the rest
    // of the campaign because the GM pressed the right arrow.
    const show = functionBody(presentJs, 'function show()');
    check('present.js has a show() to read', !!show);
    check('and moving between pictures sends nothing', !!show && !/\bapi\(/.test(show),
      'show() talks to the API');
    const goTo = functionBody(presentJs, 'function goTo(at)');
    check('nor does stepping to a picture', !!goTo && !/toggleReveal/.test(goTo));

    // The keys: arrows, and the two a presenter's clicker sends. NOT the space
    // bar - space activates whatever button has focus, and the button most
    // likely to have it on this page is the one that reveals.
    const fromKeydown = presentJs.slice(presentJs.indexOf("addEventListener('keydown'"));
    const keyBlock = fromKeydown.slice(0, fromKeydown.indexOf('});'));
    check('the keydown handler is readable', keyBlock.length > 0 && keyBlock.length < 1200);
    check('arrows and a clicker move through the page',
      /ArrowRight/.test(keyBlock) && /ArrowLeft/.test(keyBlock)
      && /PageDown/.test(keyBlock) && /PageUp/.test(keyBlock));
    check('Escape leaves', /e\.key === 'Escape'/.test(keyBlock) && /function leave\(\)/.test(presentJs));
    check('and no key press reveals anything',
      !/toggleReveal/.test(keyBlock) && !/' '/.test(keyBlock) && !/Spacebar|'Space'/.test(keyBlock));

    // ── no chrome, and the omissions are the feature ──
    // Every other page of the five mounts the shared header. This one must
    // not: what is on the screen is what the party is looking at. Asserted
    // rather than left to a comment, for the reason index.html's missing
    // stylesheet is asserted above.
    //
    // ALL THREE MATCH CODE RATHER THAN THE WORD - the attribute inside a tag,
    // the script tag, the property access. Written as bare word searches they
    // failed on the very comments in those files that explain the omissions,
    // which is a check policing prose. Both halves of that were true at once
    // and only the loud half showed.
    check('present mode mounts no app switcher',
      !/<[^>]*data-appnav/.test(presentHtml) && !/<script[^>]+appnav\.js/.test(presentHtml));
    // A caption is the one piece of the GM's text that reaches a screen the
    // party can see. It is set as textContent, and the page loads no escaping
    // helper because it writes no markup at all.
    check('the page writes no markup',
      !/\.innerHTML/.test(presentJs) && !/<script[^>]+ui\.js/.test(presentHtml));
    check('and the caption is set as text', /\$\('caption'\)\.textContent/.test(presentJs));
    check('it reads the GM-only entry endpoint',
      /api\(`campaigns\/\$\{campaignId\}\/entries\/\$\{entryId\}`\)/.test(presentJs));
    // A City Creator city (?city_id=, Phase 4c) is shown from the SERVER's
    // player view and nothing else - never the G.M.'s whole city, which this
    // page would then have to hide parts of. Drawn with DOM calls, so the
    // no-markup check above still covers it, and it adds no write.
    const cityPart = presentJs.slice(presentJs.indexOf('async function loadCity()'),
      presentJs.indexOf('// ---------- the chrome'));
    check('a city is shown from the players\' view, and only from it',
      /api\(`cities\/\$\{cityId\}\/view`\)/.test(cityPart) && !/api\(`cities\/\$\{cityId\}`\)/.test(presentJs)
        && (presentJs.match(/\bapi\(`/g) || []).length === 3, `${(presentJs.match(/\bapi\(`/g) || []).length} api() calls`);

    // ── the way in, and the way back ──
    check('the dashboard offers Present on a picture and on a page',
      /presentUrl\(i\.id\)/.test(dash) && /presentUrl\(\)/.test(dash));
    check('and the link carries the campaign and the page',
      /present\.html\?campaign_id=\$\{encodeURIComponent\(campaignId\)\}&entry_id=/.test(dash));
    // Leaving lands on the page that was being presented rather than at the
    // top of the roster, which takes both ends: present.js names the page in
    // the URL it goes back to, and the dashboard opens what it is handed.
    check('leaving returns to the page it was presenting',
      /q\.set\('entry_id', entryId\)/.test(presentJs) && /'\/apps\/gm-tools\/'/.test(presentJs));
    check('and the dashboard reopens that page',
      /const openEntryId = /.test(dash) && /if \(D\.isGm && openEntryId\) await openEntry\(openEntryId\)/.test(dash));

    // ── the stage ──
    // The slice runs to the end of the file, which is where this block sits. A
    // section appended after it would be judged by these three as well - a
    // false failure, and the loud kind, which is the trade printCss's header
    // argues for over a slice that silently stops matching.
    const stage = css.slice(css.indexOf('body.present {'));
    check('the present-mode block is in the shared stylesheet', stage.length > 0);
    // Black rather than --bg-primary, and the only page in the suite that
    // departs from the palette: this background is the surround of a
    // photograph rather than a surface the UI stands on.
    check('the stage is black and the picture is fitted, never cropped',
      /background:\s*#000/.test(stage) && /object-fit:\s*contain/.test(stage)
      && /max-height:\s*100dvh/.test(stage));
    check('and it still casts no shadow', !/box-shadow/.test(stage));
    check('the chrome fades when nothing is happening',
      /body\.present\.idle \.present-chrome \{ opacity: 0; \}/.test(stage));
  }

  // ---------- Statted NPCs: one panel, two pages ----------
  // The G.M.'s statted-NPC panel - rolling from a class, placing a notable NPC,
  // rolling creatures, linking a sheet to a dossier - was written into the
  // campaign page, and GM Tools needed it too. It lives in js/npc-sheets.js and
  // both pages mount it, so there is ONE copy of every roller call: a second
  // copy is the one a fix never reaches. And both mount it only for the G.M.
  // The server is the real guard (the roster request sends kind = 'npc' rows to
  // the G.M. alone, and regression proves it); this pins that neither page asks
  // for the panel's endpoints on a player's behalf.
  section('Statted NPCs: one panel, two pages');
  {
    const panel = readFileSync(join(appDir, 'js', 'npc-sheets.js'), 'utf8');
    // The panel builds the two book paths from one `endpoint` field, so the
    // route's last segment is what both sides are read for.
    const rollers = ['npcs/generate', 'from-notable', 'from-creature'];
    check('the panel calls all three rollers', rollers.every((r) => panel.includes(r)));
    for (const [dir, file] of [['campaign', 'campaign.js'], ['gm-tools', 'dashboard.js']]) {
      const html = readFileSync(join(repoRoot, 'apps', dir, 'index.html'), 'utf8');
      const js = readFileSync(join(repoRoot, 'apps', dir, file), 'utf8');
      check(`${dir} loads the shared panel`, html.includes('/apps/character-creator/js/npc-sheets.js'));
      const own = rollers.filter((r) => js.includes(r));
      check(`${dir} carries no roller of its own`, own.length === 0, own.join(', '));
      // Exactly one mount, inside a function the render calls only behind isGm.
      const mountFn = (js.match(/function (\w+)\(\) \{\s*return npcSheets\.mount\(/) || [])[1];
      check(`${dir} mounts it once, and only for the G.M.`,
        !!mountFn && (js.match(/npcSheets\.mount\(/g) || []).length === 1
          && js.includes(`\${D.isGm ? ${mountFn}() : ''}`), mountFn || 'no mount function');
      // The library (migration 079) is the panel's too, so both pages have it
      // and neither has a copy.
      check(`${dir} reaches the NPC library only through the shared panel`, !/npc-library/.test(js));
    }
    // Keep, pull and roll-into-library all live in the panel. A pull into a
    // campaign of a different game is the SERVER's refusal (409) and goes in
    // only after the G.M. confirms - `force` is never sent first.
    const pull = panel.slice(panel.indexOf('async function pull('), panel.indexOf('async function patchEntry('));
    check('the panel keeps, pulls and rolls into the library',
      /api\('npc-library', \{/.test(panel) && /`npc-library\/\$\{id\}\/pull`/.test(panel)
        && /body\.to_library = true/.test(panel) && /to_library: true/.test(panel));
    check('and forces a pull across games only after a 409 and a yes',
      /async function pull\(id, force = false\)/.test(pull)
        && /err\.status === 409 && err\.detail\?\.code === 'system_mismatch'\s*&& confirm\(/.test(pull)
        && /return pull\(id, true\)/.test(pull));
  }

  // ---------- The name panel beside every Name box ----------
  // Phase 4b of the NPC work: a 🎲 beside all four Name boxes - the class
  // roller's, the notable picker's, the creature picker's and the dossier form's
  // - opens js/name-panel.js. The names come from the G.M.-only list request,
  // so the panel holds no word list and cannot top a short list up; a click
  // fills the box through its own change handler. Names go into inline
  // handlers, so they are escaped for the attribute AND the JS string
  // (escJs - the O'Brien bug, memory: escaping-into-markup).
  section('The name panel beside every Name box');
  {
    const panel = readFileSync(join(appDir, 'js', 'name-panel.js'), 'utf8');
    const sheets = readFileSync(join(appDir, 'js', 'npc-sheets.js'), 'utf8');
    const camp = readFileSync(join(repoRoot, 'apps', 'campaign', 'campaign.js'), 'utf8');
    check('the roller\'s Name box has a 🎲 and the panel under it',
      /namePanel\.button\('npcgen-name'/.test(sheets) && /namePanel\.slot\('npcgen-name'\)/.test(sheets));
    check('so do both book pickers\' Name boxes',
      /id="npc\$\{which\}-name"/.test(sheets) && /namePanel\.button\(`npc\$\{which\}-name`/.test(sheets)
        && /namePanel\.slot\(`npc\$\{which\}-name`\)/.test(sheets));
    check('and the dossier form\'s, for the G.M. only, offering every kind',
      /D\.isGm \? namePanel\.button\('npc-name', \{ kinds: 'all' \}\)/.test(camp)
        && /D\.isGm \? namePanel\.slot\('npc-name'\)/.test(camp));
    for (const dir of ['campaign', 'gm-tools']) {
      const html = readFileSync(join(repoRoot, 'apps', dir, 'index.html'), 'utf8');
      const a = html.indexOf('js/name-panel.js');
      check(`${dir} loads the name panel before the panel that draws its buttons`,
        a > 0 && a < html.indexOf('js/npc-sheets.js'));
    }
    check('the panel asks a name list and nothing else for names - the campaign\'s, or with no campaign the campaign-free one',
      (panel.match(/await api\(/g) || []).length === 2
        && panel.includes('api(S.host.campaignId ? `campaigns/${S.host.campaignId}/names?${qs}` : `names?${qs}`)')
        && panel.includes('`names/themes?system='));
    // The character wizard (Phase 4c): the same panel, at no table.
    const wizard = readFileSync(join(appDir, 'app.js'), 'utf8');
    const wizHtml = readFileSync(join(appDir, 'index.html'), 'utf8');
    const review = wizard.slice(wizard.indexOf('function renderReview()'), wizard.indexOf('<h3>${esc(S.cls.name)}'));
    check('the wizard\'s name box has the 🎲 and the panel under it, at no campaign',
      /namePanel\.init\(\{ campaignId: null, system: S\.system \}\);/.test(review)
        && /namePanel\.button\('char-name', \{ classes: nameClasses \}\)/.test(review)
        && /namePanel\.slot\('char-name'\)/.test(review));
    check('and loads the panel before the page that draws its button',
      wizHtml.indexOf('js/name-panel.js') > 0 && wizHtml.indexOf('js/name-panel.js') < wizHtml.indexOf('app.js'));
    check('a new game reloads the themes and resets every box',
      /if \(was !== undefined && was !== host\.system\) \{\s*S\.meta = null;/.test(panel));
    const free = readFileSync(join(repoRoot, 'functions', 'api', 'character-creator', 'names.js'), 'utf8');
    check('the campaign-free list reads no campaign: only the chips on screen are left out',
      !/usedNames|env\.DB|requireCampaign/.test(free) && /generateNames\(\{ \.\.\.q, exclude: q\.avoid \}\)/.test(free));
    check('and never adds a chip the server did not send - a short list stays short',
      !/chips\.push\(|chips\.unshift\(|chips\.splice\(/.test(panel)
        && /b\.chips = \[\.\.\.keep, \.\.\.res\.names\];/.test(panel));
    check('a chip escapes the name twice for its handler and once for its text',
      /const sn = escJs\(name\)/.test(panel) && /namePanel\.use\('\$\{sid\}', '\$\{sn\}'\)/.test(panel)
        && /\$\{esc\(name\)\}<\/button>/.test(panel));
    const roll = sheets.slice(sheets.indexOf('async function roll()'), sheets.indexOf('// ---------- from the books'));
    check('"a different name for each" sends the theme and not the Name box',
      /if \(g\.each\) Object\.assign\(body, await namePanel\.batchOptions\(/.test(roll)
        && /else body\.name = /.test(roll));
  }
}
