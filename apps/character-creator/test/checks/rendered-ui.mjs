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

import { existsSync, readdirSync, readFileSync } from 'node:fs';
import { join } from 'node:path';

import { appDir, repoRoot, check, section, wantSection, appPath } from '../harness.mjs';
import { fixedFormulaValue } from '../../js/dice.js';
import { parseClassMarkdown } from '../../js/parser.js';
import { buildProposal, spellTraditionAllowed, spellTraditionsAllowed } from '../../js/leveling.js';

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
// The body ends at the first `}` standing at the SIGNATURE'S OWN INDENT, so a
// function inside a module's IIFE (shared/js/campaign/, two spaces in) is read
// to its own close rather than to the end of the whole module - which is where
// a column-0 `}` would be. A top-level function reads exactly as it always did.
function functionBody(src, signature) {
  const from = src.indexOf(signature);
  if (from === -1) return null;
  const indent = /[ \t]*$/.exec(src.slice(src.lastIndexOf('\n', from) + 1, from))[0];
  const rest = src.slice(from);
  const end = rest.search(new RegExp(`\\r?\\n${indent}\\}`));
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
  'The browser Back button walks the wizard steps',
  'A forward jump on the rail stops where Forward does',
  'A wizard control keeps keyboard focus when its own change redraws the step',
  'Undo instead of confirm for one-row deletes',
  'The GM dashboard',
  'The printed sheet',
  'Play mode is a mode, not a layout',
  'Trackable resources',
  'The session log',
  'Two people, one character',
  'Board & Tissue: the chip column and the mark',
  'The front door agrees with the rooms',
  'A typed override is drawn as text',
  'A levelled-up spell pick keeps to the traditions of its class',
  'The wizard and the codex head a held list by its tradition',
  'Changes that could not be sent',
  'A redraw keeps what was typed',
  'A refused save keeps what was typed since',
  'A form switch waits for what was typed',
  'A skill roll stops at 98',
  'The Hit to picker follows the armour list',
  'A row behind an Undo stays off the screen',
  'A vessel keeps every location typed into it',
  'The weapon cards follow the inventory',
  'An item that was not added leaves no note saying it was',
  'Pool presses go out one at a time',
  'A power spend is guarded on the number it was made from',
  'An overflow that was refused is still on offer',
  'A value is escaped for the place it is written into',
  'The sheet reads only item fields its endpoint sends',
  'The codex',
  'One header for five apps',
  'Present mode shows without revealing',
  'The campaign views are shared, and style nothing',
  'Statted NPCs: one panel, two pages',
  'The name panel beside every Name box',
];

export async function run() {
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
    // The picture upload is the shared setting view's (shared/js/campaign/),
    // and the downscaler moved beside it, so every game's GM page has both.
    const campaignJs = join(repoRoot, 'shared', 'js', 'campaign');
    const down = readFileSync(join(campaignJs, 'downscale.js'), 'utf8');
    const gmHtml = readFileSync(join(repoRoot, 'apps', 'gm-tools', 'index.html'), 'utf8');
    // Matched as SCRIPT TAGS, not as bare filenames: the comment above the tag
    // names the file it loads before, and a plain indexOf found that first and
    // reported the order backwards. The same shape of mistake the appnav
    // checks make.
    const tagAt = (f) => gmHtml.indexOf(`<script src="${f}"`);
    check('the downscaler is loaded before the view that uses it',
      tagAt('/shared/js/campaign/downscale.js') > 0
      && tagAt('/shared/js/campaign/downscale.js') < tagAt('/shared/js/campaign/setting.js'),
      'downscale.js is missing or loads after setting.js');
    // THE TABLE'S PANEL IS ON THE PAGE A CAMPAIGN CLICK LANDS ON. It shipped on
    // the Campaign page alone, and the campaign list sends a click on the
    // campaign's name to GM Tools (the Campaign page is the small Notes button
    // beside it), so on production the GM never saw Open the table. The
    // landing page is read off the list's own first link, so a list that moves
    // the click moves this check with it.
    const listSrc = readFileSync(join(repoRoot, 'apps', 'character-creator', 'js', 'campaign-list.js'), 'utf8');
    const landing = (listSrc.match(/href="\/apps\/([a-z-]+)\/\?campaign_id=/) || [])[1];
    const landHtml = landing ? readFileSync(join(repoRoot, 'apps', landing, 'index.html'), 'utf8') : '';
    const landJs = [...landHtml.matchAll(/<script src="([^/"][^"]*)"/g)]
      .map((m) => readFileSync(join(repoRoot, 'apps', landing, m[1]), 'utf8')).join('\n');
    check(`the page a campaign click lands on (${landing || 'none found'}) shows The Table's panel`,
      !!landing && landHtml.includes('<script src="/shared/js/campaign/table.js"')
      && /\.table\.load\(\)/.test(landJs) && /\.table\.html\(\)/.test(landJs),
      'table.js is not loaded there, or the page never loads or draws the panel');
    // THE HEADER COMES FROM THE BLOB. The server reads that one header for the
    // R2 key's extension, the stored content_type AND the Content-Type it
    // serves later, so a re-encoded blob described by the original file's type
    // is wrong in three places at once. The finding's text omitted this.
    const dashSrc = readFileSync(join(campaignJs, 'setting.js'), 'utf8');
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
    const campSrc = readFileSync(join(campaignJs, 'people.js'), 'utf8');
    // THE PATH IS THE PART THE FINDING GOT WRONG. It proposed `js/downscale.js`,
    // and apps/campaign has no js/ directory - that tag 404s, leaves `downscale`
    // undefined, and every portrait upload dies in uploadPortrait's own catch.
    // Matched as a script tag with the absolute src, so a relative one fails
    // here rather than in a GM's browser.
    const campTagAt = (f) => campHtml.indexOf(`<script src="${f}"`);
    check('the campaign page loads the downscaler by absolute path',
      campTagAt('/shared/js/campaign/downscale.js') > 0
      && campTagAt('/shared/js/campaign/downscale.js') < campTagAt('/shared/js/campaign/people.js'),
      'downscale.js is missing, relative, or loads after people.js');
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
      /<div id="play-roll-bar"[\s\S]{0,200}<div id="roll-line"[^>]*>/.test(src)
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
    // rebuilds the button that was pressed, mid-press. Four writers of the
    // line: a roll, an armour hit, the history toggle, and an overflow offer
    // put back after the server refused it.
    check('a roll rewrites the line and not the bar',
      !/\$\('play-roll-bar'\)/.test(src) && (src.match(/\$\('roll-line'\)/g) || []).length === 4,
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

    // A FOURTH reader, found later: the mirror of a typed write into the page's
    // own copy. RUN against the real poolMax, because the three above were
    // pinned as text and this one sat beside them reading the rolled maximum
    // the whole time.
    const mirrorAt = sheetSrc.indexOf('function applyToData(');
    const mirrorEnd = mirrorAt < 0 ? -1 : sheetSrc.slice(mirrorAt).search(/\r?\n\}/);
    check('the typed-write mirror can be located', mirrorEnd > 0, 'function applyToData( moved');
    const mirror = (data, vals) => {
      const C = { data: { ...data } };
      try {
        new Function('C', 'poolMax',
          sheetSrc.slice(mirrorAt, mirrorAt + mirrorEnd) + '\n}\nreturn applyToData;')(C, pm)(vals);
      } catch (e) { return { threw: e.message }; }
      return C.data;
    };
    // What the PATCH stores: the clamp itself, cut out of the route and run
    // against the row the route would have read. Until 2026-10-22 this was a
    // copy of the clamp written here, which agreed with the page whatever the
    // route did.
    const idSrc = readFileSync(join(appDir, '..', '..', 'functions', 'api', 'character-creator',
      'characters', '[id].js'), 'utf8');
    // The slice runs from the first statement of the clamp to the `sets.push`
    // that stores the result, cut back to its last `;` so the braces closing
    // the block and the loop are left out. (The clamp's last line also occurs
    // in the bulk route below, so it cannot be the end marker.)
    const CLAMP_START = "let max = current?.[field.replace('_current', '_max')];";
    const clampAt = idSrc.indexOf(CLAMP_START);
    const clampStop = clampAt < 0 ? -1 : idSrc.indexOf('sets.push(', clampAt);
    check('the PATCH clamp can be located', clampAt >= 0 && clampStop > clampAt, 'the clamp in [id].js moved');
    const clampBody = clampStop > clampAt ? idSrc.slice(clampAt, clampStop) : '';
    const clampSrc = clampBody.slice(0, clampBody.lastIndexOf(';') + 1);
    const serverStores = (current, key, v) => {
      try { return new Function('current', 'field', 'v', clampSrc + '\nreturn v;')(current, key + '_current', v); }
      catch (e) { return 'threw ' + e.message; }
    };
    const burned = { ppe_max: 30, ppe_base_spent: 10, ppe_current: 5, isp_max: 40, isp_current: 1, hp_current: 3 };
    check('P.P.E. typed back up to the rolled maximum is held at what is left of it',
      mirror(burned, { ppe_current: 30 }).ppe_current === 20, JSON.stringify(mirror(burned, { ppe_current: 30 })));
    const cases = [['ppe', 30], ['ppe', 20], ['ppe', 7], ['ppe', -4], ['isp', 99], ['isp', 12], ['hp', 500]];
    const shows = ([key, v]) => mirror(burned, { [key + '_current']: v })[key + '_current'];
    const off = cases.filter((c) => shows(c) !== serverStores(burned, c[0], c[1]));
    check('and for every pool the page then shows what the server stored', off.length === 0,
      off.map((c) => c[0] + ' ' + c[1] + ': page ' + shows(c) + ', server ' + serverStores(burned, c[0], c[1])).join(' | '));
    check('anything that is not a pool is copied as it is',
      mirror(burned, { notes: 'x' }).notes === 'x' && mirror(burned, { ppe_current: null }).ppe_current === null);

    // And the server, which is what actually stops a refill past the spend.
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

  // The browser's Back button used to leave the wizard from whatever step it
  // was on: app.js kept no history, so the only guard was the unload prompt.
  // Each visit to a step is an entry now, the step in history.state only
  // (Nate, 2026-10-12: not the URL hash), and Back walks visits. Text checks,
  // because no gating suite drives a browser (Nate, 2026-10-15); the drive in
  // real Chrome is in the pull request that added this.
  section('The browser Back button walks the wizard steps');
  {
    const app = readFileSync(join(appDir, 'app.js'), 'utf8');
    const render = functionBody(app, 'function render() {');
    const record = functionBody(app, 'function stepHistory() {');
    const go = functionBody(app, 'function goStep(i) {');
    const reach = functionBody(app, 'function reachableStep(want) {');
    const popAt = app.indexOf("window.addEventListener('popstate'");
    const pop = popAt === -1 ? null : app.slice(popAt, app.indexOf('\n});', popAt));
    check('render(), stepHistory(), goStep(), reachableStep() and a popstate listener are all found',
      !!render && !!record && !!go && !!reach && !!pop,
      `render ${!!render}, stepHistory ${!!record}, goStep ${!!go}, reachableStep ${!!reach}, popstate ${!!pop}`);
    if (render && record && go && reach && pop) {
      // Recorded at the end of render() and after the home and saved views
      // have returned, so only a wizard step is ever an entry.
      const saved = render.indexOf('return renderSaved()');
      const call = render.indexOf('stepHistory();');
      check('every wizard render records its step, and the home and saved views do not',
        saved !== -1 && call > saved, 'render() no longer calls stepHistory() after the saved view returns');
      check('goStep() reaches it through render()', /\brender\(\)/.test(go), 'goStep no longer renders');
      check('and the rail\'s step buttons go through goStep()',
        /onclick="goStep\(\$\{i\}\)"/.test(app), 'the rail no longer calls goStep');
      check('a step changed by render pushes an entry whose state names the step and its place',
        /history\.pushState\(\{ wizStep: S\.step, wizBuild: histBuild, wizPos: histPos \}, ''\)/.test(record)
          && /histPos = here \+ 1;/.test(record),
        'stepHistory does not push { wizStep, wizPos } for a new step');
      check('and a render on the step already recorded pushes nothing',
        /at\.wizStep === S\.step\) return;/.test(record), 'every render pushes, so a keystroke is a history entry');
      check('the first render of a build replaces the entry it lands on instead of pushing',
        /at\?\.wizBuild !== histBuild\) \{\s*histPos = here;\s*history\.replaceState\(/.test(record),
        'a new build pushes its first step, so Back on it does not leave the page');
      for (const fn of ['async function newCharacter()', 'function startWithClass(c)', 'function resumeDraft()', 'function startOver()']) {
        const body = functionBody(app, fn);
        check(`${fn.replace(/^(async )?function /, '')} starts a fresh history`,
          !!body && /freshHistory\(\);/.test(body), `${fn} carries the last build's history on`);
      }
      // The step is in the state only. A URL argument, or any write to the
      // address, would put it in the address bar (the ruling not taken).
      check('the step never reaches the address',
        !/history\.(pushState|replaceState)\(\{[^}]*\}, '', /.test(app) && !/location\.hash\s*=[^=]/.test(app),
        'a history call or an assignment carries the step into the URL');
      check('the popstate listener sets the step from the entry and renders',
        /S\.step = reachableStep\(want\)/.test(pop) && /render\(\)/.test(pop) && /ev\.state\?\.wizStep/.test(pop),
        'popstate no longer restores the step');
      check('and renders without pushing',
        /histRestoring = true/.test(pop) && !/pushState/.test(pop)
          && /if \(histRestoring \|\| /.test(record),
        'a Back would add an entry, so Forward is lost and history grows on every press');
      // Entries outlive their build: Chrome keeps them across a reload, and a
      // second build in the tab sits after the first. Passed over, so Back on
      // a build's first step still leaves the page.
      check('another build\'s entry, or one reached from the home or saved view, is passed over',
        /ev\.state\.wizBuild !== histBuild \|\| S\.home \|\| S\.savedId\) \{\s*if \(dir\) history\.go\(dir\);\s*return;/.test(pop),
        'popstate shows an old build\'s step, or redraws a step over the home or saved view');
      check('in the direction the button was going',
        /const dir = Math\.sign\(pos - histPos\);/.test(pop), 'popstate cannot tell Back from Forward');
      // Back never undoes a class or system change, and never passes a gate.
      check('Back and Forward land no higher than the furthest step reached',
        /S\.maxStep \?\? 0/.test(reach), 'an entry above maxStep is shown as it stands');
      check('nor past a step whose own Next button is refusing',
        /forwardStop\(/.test(reach), 'Forward walks past a blocked step');
      check('nor on a step that does not apply', /!stepApplies\(i\)/.test(reach),
        'an entry naming a skipped step is shown');
      check('and change nothing but the step',
        !/pickClass|pickSystem|resetBuild|recompose|S\.rcc\s*=/.test(pop + reach),
        'Back reapplies or undoes a class or system change');
    }
  }

  // The rail made a visited step past the current one a button whenever the
  // CURRENT step had no blocker, so a jump from Race to Skills walked past an
  // unmet Attributes minimum that Forward stops at. Rendered rather than read:
  // renderStepper(), reachableStep() and the walk they share are lifted out of
  // app.js and drawn against a stand-in build, with every step on the rail
  // compared with where Forward would land.
  section('A forward jump on the rail stops where Forward does');
  {
    const app = readFileSync(join(appDir, 'app.js'), 'utf8');
    const stepper = functionBody(app, 'function renderStepper() {');
    const reach = functionBody(app, 'function reachableStep(want) {');
    const stop = functionBody(app, 'function forwardStop(to) {');
    const steps = app.match(/const STEPS = \[[^\]]*\];/)?.[0];
    const named = app.match(/const ST = Object\.fromEntries\([^\n]*/)?.[0];
    const num = app.match(/const stepNum = \(i\) => [^\n]*/)?.[0];
    check('renderStepper(), reachableStep(), forwardStop(), STEPS, ST and stepNum are all found',
      !!stepper && !!reach && !!stop && !!steps && !!named && !!num,
      `renderStepper ${!!stepper}, reachableStep ${!!reach}, forwardStop ${!!stop}, STEPS ${!!steps}, ST ${!!named}, stepNum ${!!num}`);
    // forwardStop() is lifted when present and the rest runs without it, so
    // the rail is still drawn and judged on a tree that has lost the helper.
    if (stepper && reach && steps && named && num) {
      const lib = new Function(`${steps}\n${named}\nreturn { STEPS, ST };`)();
      const { ST } = lib;
      const N = lib.STEPS.length;
      // One build drawn: `blocked` are the steps whose own Next refuses, `na`
      // the steps that do not apply. Returns the indices the rail made buttons
      // and the step Forward would land on for each wanted step.
      const draw = ({ step, maxStep, blocked = [], na = [] }) => {
        const page = { stepper: { innerHTML: '' } };
        const S = { step, maxStep, home: false, rcc: { name: 'X' } };
        const built = new Function('S', 'stepBlocker', 'stepApplies', '$', 'document', 'sticky',
          'summaryItems', 'draftWorthSaving', 'esc',
          `${steps}\n${named}\n${num}\n${stop ? `${stop}\n}` : ''}\n${reach}\n}\n${stepper}\n}\nreturn { renderStepper, reachableStep };`)(
          S, (k) => (blocked.includes(k) ? 'blocked' : ''), (k) => !na.includes(k),
          (id) => page[id], { querySelector: () => null }, { sizeSticky() {} },
          () => [], () => false, (x) => String(x));
        built.renderStepper();
        const rail = page.stepper.innerHTML.match(/<div class="step-rail">([\s\S]*?)<\/div>/)?.[1] || '';
        const buttons = [...rail.matchAll(/<button [^>]*onclick="goStep\((\d+)\)"/g)].map((m) => Number(m[1]));
        return { buttons, reach: built.reachableStep };
      };

      // The row's own case: on Race, Skills visited, Attributes refusing.
      const race = draw({ step: ST.RACE, maxStep: ST.SKILLS, blocked: [ST.ATTRIBUTES] });
      check('on Race with Skills visited and Attributes blocked, no step past Attributes is a button',
        race.buttons.every((i) => i <= ST.ATTRIBUTES), `buttons ${race.buttons.join(',')}`);
      check('but Attributes itself is, since Race lets you leave it',
        race.buttons.includes(ST.ATTRIBUTES), `buttons ${race.buttons.join(',')}`);
      check('and Forward to Skills stops on Attributes too', race.reach(ST.SKILLS) === ST.ATTRIBUTES,
        `Forward lands on ${race.reach(ST.SKILLS)}`);

      // Every placement of one blocked step, with and without a step that does
      // not apply in the way: a step past the current one is a button exactly
      // when Forward to it lands on it.
      const wrong = [];
      for (const na of [[], [ST.MORPHUS], [ST.OCCUPATION, ST.MORPHUS]]) {
        for (let b = 0; b < N; b++) {
          for (const step of [ST.SYSTEM, ST.RACE, ST.ATTRIBUTES]) {
            if (na.includes(step)) continue;
            const maxStep = N - 1;
            const w = draw({ step, maxStep, blocked: [b], na });
            for (let i = step + 1; i <= maxStep; i++) {
              if (na.includes(i)) continue;
              if (w.buttons.includes(i) !== (w.reach(i) === i)) {
                wrong.push(`on ${step}, ${b} blocked, na [${na}]: step ${i} button ${w.buttons.includes(i)}, Forward lands ${w.reach(i)}`);
              }
            }
          }
        }
      }
      check('across every blocked step, the rail offers a forward step exactly when Forward reaches it',
        wrong.length === 0, wrong.slice(0, 4).join('; '));

      const open = draw({ step: ST.RACE, maxStep: ST.SKILLS });
      check('with nothing blocked, every visited step is a button and none past the furthest reached',
        [ST.SYSTEM, ST.ATTRIBUTES, ST.OCCUPATION, ST.MORPHUS, ST.SKILLS].every((i) => open.buttons.includes(i))
          && open.buttons.every((i) => i <= ST.SKILLS),
        `buttons ${open.buttons.join(',')}`);
      const stuck = draw({ step: ST.RACE, maxStep: ST.SKILLS, blocked: [ST.RACE] });
      check('and a blocked current step offers nothing forward, only the steps behind it',
        stuck.buttons.join(',') === String(ST.SYSTEM), `buttons ${stuck.buttons.join(',')}`);

      check('the rail and Forward share the walk rather than each keeping a copy',
        !!stop && /forwardStop\(/.test(stepper) && /forwardStop\(/.test(reach) && /stepBlocker\(k\)/.test(stop)
          && !/stepBlocker\(/.test(stepper) && !/stepBlocker\(/.test(reach),
        'renderStepper or reachableStep reads stepBlocker itself');
    }
  }

  // Every step renderer replaces #app whole and the rail replaces #stepper, so a
  // control whose own change calls render() used to be destroyed while it had
  // focus: a manual attribute left by Tab, a method or starting-level select, a
  // skill checkbox toggled by Space, each dropped a keyboard user onto the body.
  // One mechanism in render(), not a patch per handler. Text checks, because no
  // gating suite drives a browser (Nate, 2026-10-15); the drive in real Chrome
  // is in the pull request that added this.
  section('A wizard control keeps keyboard focus when its own change redraws the step');
  {
    const app = readFileSync(join(appDir, 'app.js'), 'utf8');
    const picker = readFileSync(join(appDir, 'js', 'picker.js'), 'utf8');
    const render = functionBody(app, 'function render() {');
    const hold = functionBody(app, 'function holdFocus() {');
    const restore = functionBody(app, 'function restoreFocus(held) {');
    const key = functionBody(app, 'function focusKey(el) {');
    const next = functionBody(app, 'function nextTabbable(from, dir) {');
    const wire = functionBody(picker, 'function wire(id, { onInput, onEnter, lone } = {}) {');
    check('render(), holdFocus(), restoreFocus(), focusKey(), nextTabbable() and Picker.wire are all found',
      !!render && !!hold && !!restore && !!key && !!next && !!wire,
      `render ${!!render}, holdFocus ${!!hold}, restoreFocus ${!!restore}, focusKey ${!!key}, nextTabbable ${!!next}, wire ${!!wire}`);
    if (render && hold && restore && key && next && wire) {
      const held = render.indexOf('const held = holdFocus();');
      check('render() notes the focused control before the rail or the step is redrawn',
        held !== -1 && held < render.indexOf('renderStepper()'), 'holdFocus() is not the first thing render() does');
      const drawn = render.indexOf('[S.step]()');
      check('and restores it after the step is drawn',
        drawn !== -1 && render.indexOf('restoreFocus(held);') > drawn, 'render() does not call restoreFocus(held) after the step renderer');
      check('by a key: the control\'s id where it has one, its own markup where it has none',
        /if \(el\.id\) return \{ id: el\.id \};/.test(key) && /focusSig\(el\)/.test(key),
        'focusKey() no longer keys a control by its id, then by its markup');
      check('a text field\'s caret is noted and put back',
        /selectionStart/.test(hold) && /setSelectionRange\(/.test(restore), 'the selection range is not carried across');
      check('the restore never scrolls the page',
        /\.focus\(\{ preventScroll: true \}\)/.test(restore), 'restoreFocus() focuses without preventScroll');
      check('and is the one place app.js moves focus',
        (app.match(/\.focus\(/g) || []).length === 1, 'app.js moves focus somewhere other than restoreFocus()');
      // A Tab that changed a field redraws under the Tab, after focus has left
      // the field and before any focusout says where it went; the keydown does.
      check('a Tab is noted at keydown, Shift+Tab as backwards',
        /addEventListener\('keydown', \(ev\) => \{\s*if \(ev\.key !== 'Tab'\) return;\s*tabbing = \{ from: ev\.target, back: ev\.shiftKey \};/.test(app),
        'no keydown listener records where a Tab started');
      check('and the redraw it caused lands focus on the control after the one left',
        /tabbing\.back \? -1 : 1/.test(hold) && /nextTabbable\(el, held\.step\)/.test(restore),
        'a Tab that redraws puts focus back on the field it left, or nowhere');
      // A step change (Next, the rail, Back) puts focus where it always did.
      check('only on the view it was noted on',
        /held\.view !== view/.test(restore) && /focusView = view;/.test(hold),
        'a step change restores focus into the new step');
      // The filter boxes were already restored by Picker.wire, which the sheet
      // still relies on; it now leaves alone a box render() already focused.
      check('Picker.wire does not restore a filter box render() already restored',
        /again && again !== el && document\.activeElement !== again/.test(wire),
        'Picker.wire focuses the filter box a second time');
    }
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
    // The campaign's deletes live in the shared views (shared/js/campaign/),
    // which reach the toast through the page's adapter - so the PAGE must load
    // the helper before its own script, which hands `undoable` over at init.
    const shared = (f) => ['shared/js/campaign', f];
    for (const [page, script, fns] of [
      ['character-sheet', 'sheet.js', [['removeItem', null], ['removeVessel', null]]],
      ['campaign', 'campaign.js', [['removeEntry', shared('notes.js')], ['remove', shared('people.js')], ['dropItem', null]]],
      ['gm-tools', 'dashboard.js', [['deletePicture', shared('setting.js')]]],
    ]) {
      const html = readFileSync(join(repoRoot, 'apps', page, 'index.html'), 'utf8');
      const pageSrc = readFileSync(join(repoRoot, 'apps', page, script), 'utf8');
      const at = (s) => html.indexOf(s);
      check(`${page} loads the helper before ${script}`,
        at('/apps/character-creator/js/undo-toast.js') > 0
          && at('/apps/character-creator/js/undo-toast.js') < at(`src="${script}"`),
        `${page}/index.html does not load undo-toast.js ahead of ${script}`);
      if (page !== 'character-sheet') {
        check(`and ${script} hands it to the shared views`, /ui: \{\s*esc: escHtml, escJs, undoable,/.test(pageSrc),
          `${script} does not pass undoable in its adapter`);
      }
      for (const [fn, where] of fns) {
        const file = where ? join(repoRoot, ...where) : join(repoRoot, 'apps', page, script);
        const src = readFileSync(file, 'utf8');
        const body = functionBody(src, `function ${fn}(`) || '';
        const label = where ? where[1] : script;
        check(`${label} ${fn}() uses the undo toast, not confirm()`,
          /undoable\(\{/.test(body) && !/confirm\(/.test(body) && !/modal\(/.test(body) && /keepalive/.test(body),
          `${fn} is back on a question, or its request would not survive the page closing`);
      }
    }
    const sheetSrc = readFileSync(join(repoRoot, 'apps', 'character-sheet', 'sheet.js'), 'utf8');
    const settingSrc = readFileSync(join(repoRoot, 'shared', 'js', 'campaign', 'setting.js'), 'utf8');
    check('and deleting a whole character, or a whole GM page, still asks first',
      /confirm\(`Delete \$\{c\.name\} \(level/.test(sheetSrc)
        && /await M\.ctx\.ui\.modal\(`Delete "\$\{S\.entry\.title\}"/.test(settingSrc),
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
    // The journal panel is the shared notes view's feed now
    // (shared/js/campaign/notes.js), placed where this page calls it.
    check('the notes come before the journal',
      js.indexOf('gm-notes') > 0 && js.indexOf('gm-notes') < js.indexOf('C.notes.feedHtml('),
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
    // WRITTEN FROM A LIVE BUG (reproduced on a local server, 2026-10-11). "Has
    // it loaded" was one flag for the page, and render() draws a NEW, closed
    // box. So after any redraw the flag still said loaded: opening the log
    // showed "Opening this loads the log." and fetched nothing, until it was
    // closed and opened a second time.
    //
    // RUN, not matched: loadLog over a stand-in page that is redrawn the way
    // render() redraws it, and a stand-in server whose answers can be held.
    {
      const lf = sheet.replace(/\r\n/g, '\n');
      const flag = (/^let logLoaded = .*;$/m.exec(lf) || [''])[0];
      const from = lf.indexOf('\nasync function loadLog() {'), to = lf.indexOf('\n}\n', from);
      const src = from < 0 || to < 0 ? null : lf.slice(from, to + 2);
      check('the log loader and what it remembers can be located', !!src && !!flag,
        'loadLog or its flag moved - nothing below would run');
      if (src && flag) {
        const settle = () => new Promise((r) => setImmediate(r));
        const page = {};
        // What render() does to the box: a new <details>, closed, and its placeholder.
        const redraw = () => {
          page['log-details'] = { open: false };
          page['log-body'] = { innerHTML: 'Opening this loads the log.' };
          return page['log-details'];
        };
        const net = { calls: 0, fail: false, held: null };
        const api = () => {
          net.calls += 1;
          return new Promise((res, rej) => {
            const answer = () => (net.fail ? rej(new Error('offline'))
              : res({ events: [{ kind: 'roll', payload: { note: 'Strike 14' }, created_at: '2026-10-11 12:00:00' }] }));
            if (net.held) net.held.push(answer); else answer();
          });
        };
        const loadLog = new Function('$', 'api', 'id', 'escHtml', flag + src + '; return loadLog;')(
          (elId) => page[elId] || null, api, 3, String);
        const shown = () => (/Strike 14/.test(page['log-body'].innerHTML) ? 'the log'
          : page['log-body'].innerHTML.replace(/<[^>]+>/g, '').trim());
        const state = () => JSON.stringify({ shown: shown(), calls: net.calls });

        let d = redraw();
        d.open = true; await loadLog();
        check('opening it loads the log', shown() === 'the log' && net.calls === 1, state());
        await loadLog();
        check('it fetches once, not on every toggle of an open box', net.calls === 1, state());

        d = redraw();
        d.open = true; await loadLog();
        check('opened again after a redraw, it loads again', shown() === 'the log' && net.calls === 2, state());

        d.open = false; await loadLog();
        d.open = true; await loadLog();
        check('closing forgets the load, so the next opening shows what happened since',
          shown() === 'the log' && net.calls === 3, state());

        d = redraw();
        net.fail = true;
        d.open = true; await loadLog();
        const failed = shown();
        net.fail = false;
        await loadLog();
        check('but a failed load stays retryable',
          /^Could not load/.test(failed) && shown() === 'the log', JSON.stringify({ failed, then: shown() }));

        // A load still in the air when the page is redrawn belongs to the old
        // box. Its failure must not unmark the new one, which loaded.
        const before = redraw();
        net.held = [];
        before.open = true; const stale = loadLog();
        const waiting = net.held; net.held = null;
        d = redraw();
        d.open = true; await loadLog();
        const fresh = shown(), afterOpen = net.calls;
        net.fail = true; waiting.forEach((answer) => answer()); await stale; await settle();
        net.fail = false;
        await loadLog();
        check('a load the redraw left behind cannot touch the box drawn since',
          fresh === 'the log' && shown() === 'the log' && net.calls === afterOpen,
          JSON.stringify({ fresh, shown: shown(), afterOpen, calls: net.calls }));
      }
    }

    // WRITTEN FROM A LIVE BUG (reproduced on a local server, 2026-10-19). The
    // recap posted its journal entry first and the 'recap' marker second. When
    // the marker failed, the entry stood, the sheet said "Recap failed", and the
    // next End session counted the same events again: two identical entries.
    // The marker goes first now (Nate, 2026-10-19). A failed marker writes no
    // entry; a failed entry after a good marker loses that one recap and says so.
    //
    // RUN, not matched: endSession over a stand-in server that can refuse the
    // marker or the entry.
    {
      const lf = sheet.replace(/\r\n/g, '\n');
      const from = lf.indexOf('\nasync function endSession() {'), to = lf.indexOf('\n}\n', from);
      const src = from < 0 || to < 0 ? null : lf.slice(from, to + 2);
      check('the end-of-session recap can be located', !!src, 'endSession moved - nothing below would run');
      if (src) {
        const run = async ({ refuse = null, server }) => {
          const alerts = [];
          const api = async (path, req) => {
            if (!req) return { events: server.events.map((e) => ({ ...e })) };
            if (path === 'journal') {
              if (refuse === 'journal') throw new Error('refused');
              server.journal.push(req.body.body);
              return { id: server.journal.length };
            }
            throw new Error('unexpected request ' + path);
          };
          const postEvent = async (kind, note) => {
            if (refuse === kind) throw new Error('refused');
            server.events.push({ id: server.events.length + 1, kind, payload: { note } });
            return { ok: true };
          };
          const endSession = new Function('api', 'postEvent', 'jsonReq', 'id', 'C', 'confirm', 'alert',
            'recordRoll', 'resetMelee', src + '; return endSession;')(
            api, postEvent, (method, body) => ({ method, body }), '7', { meleeAttacks: 2 },
            () => true, (m) => alerts.push(m), () => {}, () => {});
          await endSession();
          return alerts;
        };
        const twoRolls = () => ({ journal: [], events: [
          { id: 1, kind: 'roll', payload: { note: 'Strike 14' } },
          { id: 2, kind: 'roll', payload: { note: 'Parry 9' } },
        ] });

        const s = twoRolls();
        const first = await run({ refuse: 'recap', server: s });
        await run({ server: s });
        check('a recap whose marker failed, then retried, is in the journal once',
          s.journal.length === 1 && first.length === 1
          && s.events.filter((e) => e.kind === 'recap').length === 1,
          JSON.stringify({ entries: s.journal.length, alerts: first, events: s.events.map((e) => e.kind) }));

        const t = twoRolls();
        const lost = await run({ refuse: 'journal', server: t });
        check('a failed journal post after a good marker says the recap was not saved',
          t.journal.length === 0 && t.events.some((e) => e.kind === 'recap')
          && lost.length === 1 && /not saved/i.test(lost[0]),
          JSON.stringify({ entries: t.journal.length, alerts: lost, events: t.events.map((e) => e.kind) }));
      }
    }

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

    // A tile with `href` in place of a slug is a site outside this repo
    // (Surf the Stream, 2026-10-21). It names no directory, so groups.mjs
    // has nothing to own and skips it; this is the check that reads it.
    // Unescaped like `icon`, so it must be a plain https URL, and the hub
    // must open it in a new tab without handing that tab window.opener.
    const outside = manifest.apps.filter((a) => 'href' in a);
    check('a tile that leaves the site is an https URL and names no directory',
      outside.every((a) => !a.slug && /^https:\/\/[a-z0-9.-]+\/[^"'<>\s]*$/.test(a.href)),
      outside.map((a) => `${a.name}=${a.slug}|${a.href}`).join(' '));
    check('and the hub opens it in a new tab, saying so on the tag',
      /href="\$\{href\}" target="_blank" rel="noopener"/.test(landing)
      && /\$\{out \? ' ↗' : ''\}<\/span>/.test(landing),
      'the external branch of card() lost target, rel or its arrow');
  }

  // ---------- A typed override is drawn as text ----------
  // "DERIVED - OVERRIDABLE": every combat and save row takes whatever is typed
  // over it and stores it as typed, because some of them are not numbers (a
  // punch is "1D4"). Two places drew such a value without treating it as text.
  // The psionic save's target went into the roll button's handler as it stood,
  // and attacks per melee went into the play strip as markup. Either ran as
  // script for whoever opened the sheet next, the G.M. included.
  //
  // RUN, not matched: the functions are cut out of sheet.js and called with the
  // page's own escapers, and what is asserted is the markup they return.
  section('A typed override is drawn as text');
  {
    const sheet = readFileSync(appPath('sheet.js'), 'utf8');
    const ui = readFileSync(join(repoRoot, 'shared', 'js', 'ui.js'), 'utf8');
    const whole = (src, sig) => { const b = functionBody(src, sig); return b === null ? null : b + '\n}'; };
    const parts = [whole(ui, 'function escHtml('), whole(ui, 'function escJs('),
      whole(sheet, 'function rollBtn('), whole(sheet, 'function playControlsHtml('),
      whole(sheet, 'function meleeLabel(')];
    // rollTarget is new with the fix, so it is optional here: against the old
    // file the checks below must FAIL, not stop at "cannot be located".
    const rollTargetSrc = whole(sheet, 'function rollTarget(') ?? '';
    check('the five functions these checks run can be located', parts.every((x) => x !== null),
      'a signature moved - nothing below would run');
    let fns = null;
    try {
      fns = new Function('C', 'meleeState', 'weaponCardsHtml', 'restPanelHtml',
        parts.join('\n') + '\n' + rollTargetSrc + '\nreturn { rollBtn, playControlsHtml };')(
        {}, () => ({ round: 1, attack: 1 }), () => '', () => '');
    } catch (e) {
      check('the roll button and the play strip run outside the page', false, e.message);
    }
    const handler = (html) => (/onclick="([^"]*)"/.exec(html) || [])[1] ?? null;
    const save = (target) => (fns ? fns.rollBtn({ kind: 'save', name: 'vs Psionics', bonus: 2, target }) : '');

    check('a save with no target rolls against nothing',
      handler(save(null)) === "rollD20('save', 'vs Psionics', 2, null)", save(null));
    check('a target typed as a number is the number',
      handler(save('12')) === "rollD20('save', 'vs Psionics', 2, 12)", save('12'));
    check('and so is one typed with its plus sign, which used to be a dead button',
      handler(save('12+')) === "rollD20('save', 'vs Psionics', 2, 12)", save('12+'));
    for (const hostile of ['0);alert(1);//', '0)" onmouseover="alert(1)', "0);alert('x');(", '<img src=x onerror=alert(1)>']) {
      const html = save(hostile);
      check('a target that is not a number writes ' + (hostile.startsWith('0') ? '0' : 'null')
        + ' and nothing else: ' + hostile,
        /^rollD20\('save', 'vs Psionics', 2, (0|null)\)$/.test(handler(html) ?? '')
          && (html.match(/="/g) || []).length === 4 && !html.includes('<img'), html);
    }

    const strip = (attacks) => (fns ? fns.playControlsHtml(false, { attacks, strike: 1 }) : '');
    const label = (html) => (/<span id="play-melee-label">([\s\S]*?)<\/span>/.exec(html) || [])[1] ?? null;
    check('attacks per melee is shown in the play strip', /attack 1 of 4$/.test(label(strip(4)) ?? ''), label(strip(4)));
    check('typed as a line of text, it is shown as that text',
      label(strip('4 (5 with a sword)'))?.endsWith('attack 1 of 4 (5 with a sword)'), label(strip('4 (5 with a sword)')));
    const marked = strip('<img src=x onerror=alert(1)>');
    check('typed as markup, it is still shown as text',
      !marked.includes('<img') && marked.includes('&lt;img src=x onerror=alert(1)&gt;'), label(marked));
    check('and the three buttons beside it take a number whatever was typed',
      (marked.match(/(nextAttack|newRound|resetMelee)\(0\)/g) || []).length === 3, marked);
  }

  // ---------- A levelled-up spell pick keeps to the class's traditions ----------
  // BOOK-INGEST-AUDIT F57 gave a class the traditions its level-gated spell
  // picks may reach, and the server has refused a spell outside them since. The
  // banked-picks panel applied the same test; the level-up picker did not. So a
  // Ley Line Walker levelling up was offered every warlock and necromancy spell
  // in the catalog, chose one, and was refused on Confirm.
  //
  // What is asserted is AGREEMENT WITH THE SERVER'S OWN RULE, spell by spell:
  // js/leveling.js is what resolvePowerPicks asks, and the sheet cannot import
  // it, so the only thing that keeps the two in step is a check that runs both.
  section('A levelled-up spell pick keeps to the traditions of its class');
  {
    const sheetSrc = readFileSync(appPath('sheet.js'), 'utf8');
    const cut = (from, to) => {
      const a = sheetSrc.indexOf(from), b = sheetSrc.indexOf(to, a);
      return a >= 0 && b > a ? sheetSrc.slice(a, b) : '';
    };
    const src = cut('function powerPickerBlock(', '// Every power slot the level-up panel')
      + cut('function pendingPowersPanel(', 'async function claimPowers(');
    const spells = [
      { name: 'Globe of Daylight', level: 1, tradition: null, system: null },
      { name: 'Air: Cloud of Steam', level: 1, tradition: 'Warlock', system: null },
      { name: 'Necro: Animate Dead', level: 1, tradition: 'necromancy', system: null },
    ];
    const run = (cls, pending = []) => {
      const C = { data: { campaign_system: 'rifts', powers: [] }, cls, spellCatalog: spells, psiCatalog: [],
        talentCatalog: [], claimingPowers: true, pendingPowers: pending,
        pendingPowersTotal: pending.reduce((n, g) => n + g.count, 0) };
      try {
        return new Function('C', 'escHtml', 'globalThis', 'poolMax',
          src + '\nreturn { powerPickerBlock, pendingPowersPanel };')(C, (x) => String(x ?? ''), {}, () => null);
      } catch (e) {
        check('the pickers run outside the page', false, e.message);
        return null;
      }
    };
    const options = (html) => [...html.matchAll(/<option value="([^"]+)"/g)].map((m) => m[1]);
    const levelUp = (cls) => {
      const fns = run(cls);
      return fns ? options(fns.powerPickerBlock(
        buildProposal({ level: 1, hp_max: null, sdc_max: null, skills: [] }, cls, 2))) : null;
    };
    const serverAllows = (cls) => spells
      .filter((x) => spellTraditionAllowed(x, spellTraditionsAllowed(cls))).map((x) => x.name);

    const none = { magic: { spells_per_level: 1 } };
    const warlock = { magic: { spells_per_level: 1, spell_traditions_allowed: ['warlock'] } };
    const both = { magic: { spells_per_level: 1, spell_traditions_allowed: ['Warlock', 'Necromancy'] } };
    check('a class naming no tradition is offered general spells only',
      JSON.stringify(levelUp(none)) === '["Globe of Daylight"]', JSON.stringify(levelUp(none)));
    check('a class naming one is offered that one beside them, whatever the capitals',
      JSON.stringify(levelUp(warlock)) === '["Globe of Daylight","Air: Cloud of Steam"]', JSON.stringify(levelUp(warlock)));
    for (const [what, cls] of [['none', none], ['one', warlock], ['two', both]]) {
      check('the level-up picker offers exactly what the server will accept: a class naming ' + what,
        JSON.stringify(levelUp(cls)) === JSON.stringify(serverAllows(cls)),
        JSON.stringify({ picker: levelUp(cls), server: serverAllows(cls) }));
    }
    // A named list replaces the gate, as it does on the server (`!list &&` there).
    const listed = { magic: { spells_schedule: [{ level: 2, count: 1, from: ['Necro: Animate Dead'] }] } };
    check('a grant naming its spells is offered them, tradition or not',
      JSON.stringify(levelUp(listed)) === '["Necro: Animate Dead"]', JSON.stringify(levelUp(listed)));

    // The banked panel reads the grant's own frozen list, through the same test.
    const banked = (traditions) => {
      const fns = run(none, [{ kind: 'spell', granted_at_level: 2, slot: 0, count: 1, spell_levels: null, traditions }]);
      return fns ? options(fns.pendingPowersPanel()) : null;
    };
    check('a banked pick keeps the traditions it was granted with',
      JSON.stringify(banked(['warlock'])) === '["Globe of Daylight","Air: Cloud of Steam"]', JSON.stringify(banked(['warlock'])));
    check('one granted with none reaches general spells only',
      JSON.stringify(banked([])) === '["Globe of Daylight"]', JSON.stringify(banked([])));
    check('and one banked before the column existed is unrestricted, as the server reads it',
      banked(null)?.length === 3 && spells.every((x) => spellTraditionAllowed(x, null)), JSON.stringify(banked(null)));
    check('both pickers ask one test, so they cannot drift apart again',
      (sheetSrc.match(/spellTraditionOk\(x, /g) || []).length === 2
        && !/g\.traditions\.some\(/.test(sheetSrc), 'a picker has its own copy of the tradition test');
  }

  // ---------- The wizard and the codex head a held list by its tradition ----------
  // BOOK-INGEST-AUDIT F123. The sheet stopped heading a Diabolist's ward
  // symbols "Spells — Level 0" in #1666; the wizard's Powers and Review steps
  // and the codex's fold count still said "Spells", "level 0", "L0" and
  // "34 spells" (seen 2026-10-19 on a local server, the Diabolist taken to
  // Review). Run, not read: the four wizard functions and the codex's list are
  // cut out of their files and called on a fixture catalog, so what is asserted
  // is the markup a player gets. An ordinary caster's output is pinned to the
  // exact string it printed before, because that must not move.
  section('The wizard and the codex head a held list by its tradition');
  {
    const win = {};
    new Function('window', readFileSync(join(appDir, 'js', 'traditions.js'), 'utf8'))(win);
    const T = win.SpellTraditions;
    const catalog = [
      { name: 'Globe of Daylight', level: 1, ppe: 2, tradition: null },
      { name: 'Ritual: Old Rite', level: 0, ppe: 5, tradition: null },
      { name: 'Air: Cloud of Steam', level: 1, ppe: 4, tradition: 'warlock' },
      { name: 'Alarm: Silent', level: 0, ppe: 1, tradition: 'ward' },
      { name: 'Condition: Agony', level: 0, ppe: 1, tradition: 'ward' },
      { name: 'Circle of Power', level: 0, ppe: 10, tradition: 'circle' },
      // One row above 0 gives a tradition levels, whatever the others say.
      { name: 'Song: Low', level: 0, ppe: 3, tradition: 'mixed' },
      { name: 'Song: High', level: 2, ppe: 6, tradition: 'mixed' },
    ];
    check('a tradition with no levels is read off the catalog, not listed',
      JSON.stringify([...T.unleveled(catalog)].sort()) === '["circle","ward"]',
      JSON.stringify([...T.unleveled(catalog)]));

    const app = readFileSync(join(appDir, 'app.js'), 'utf8');
    const bodies = ['function listSection(', 'function reviewSpellSections(',
      'function grantedSpellHtml(', 'function startingSpellHtml('].map((s) => functionBody(app, s));
    check('the four wizard functions can be cut out of app.js', bodies.every(Boolean),
      'a signature moved, or its closing brace is no longer at its own indent');
    const S = { spellCatalog: catalog, cls: { magic: { type: 'ward' } } };
    let start = null;
    const wizard = bodies.every(Boolean) ? new Function('S', 'esc', 'REVIEW_COLUMN', 'SpellTraditions',
      'startingPicksFor', 'misfiledSpellNote', 'tieredStartHtml', 'spellGroupRows', 'spellTraditionAllowed',
      bodies.map((b) => b + '\n}').join('\n')
        + '\nreturn { reviewSpellSections, startingSpellHtml };')(
      S, (x) => String(x ?? ''), 20, T, () => start, () => '',
      (groups, o) => o.head(0), () => '', () => true) : null;
    const text = (html) => html.replace(/<[^>]+>/g, ' ').replace(/&mdash;/g, '—').replace(/&middot;/g, '·')
      .replace(/\s+/g, ' ').trim();
    const heads = (html) => [...html.matchAll(/<h3>([\s\S]*?)<\/h3>/g)].map((m) => text(m[1]));
    const powers = (granted, groups = []) => {
      start = { applicable: true, groups, granted, total: 1, misfiled: 0 };
      return wizard ? wizard.startingSpellHtml() : '';
    };

    const ward = powers(['Alarm: Silent', 'Condition: Agony']);
    check('Powers: a list of ward symbols is headed by its tradition, not "Spells"',
      heads(ward)[0] === 'Ward Symbols — 2 known (ward magic · granted by the class)', JSON.stringify(heads(ward)));
    const says = (html) => text(html.match(/<p class="muted small">([\s\S]*?)<\/p>/)?.[1] ?? '');
    check('and the sentence under it counts them as symbols, not spells',
      says(ward).startsWith('The book names this class\'s symbols outright'), says(ward));
    check('and its rows carry no "level 0", only the cost',
      !/level 0/.test(ward) && /Alarm: Silent <span class="muted small">&mdash; 1 P.P.E.<\/span>/.test(ward), text(ward));
    check('and beside picks it says the same, "granted by the class"',
      heads(powers(['Alarm: Silent'], [{}]))[0] === 'Ward Symbols — 1 granted by the class (already on the character)',
      JSON.stringify(heads(powers(['Alarm: Silent'], [{}]))));
    S.cls = { magic: { type: 'spell' } };
    const plain = powers(['Globe of Daylight']);
    check('an ordinary caster\'s granted list reads exactly as it did',
      heads(plain)[0] === 'Spells — 1 known (spell magic · granted by the class)'
        && /Globe of Daylight <span class="muted small">&mdash; level 1, 2 P.P.E.<\/span>/.test(plain), text(plain));
    check('and its sentence still says "spells"',
      says(powers(['Globe of Daylight', 'Ritual: Old Rite'])).startsWith('The book names this class\'s spells outright'),
      says(powers(['Globe of Daylight', 'Ritual: Old Rite'])));
    check('and a list mixing traditions stays "Spells"',
      !!heads(powers(['Globe of Daylight', 'Air: Cloud of Steam']))[0]?.startsWith('Spells — 2 known'),
      JSON.stringify(heads(powers(['Globe of Daylight', 'Air: Cloud of Steam']))));
    check('and so does its sentence, wards in the mix included',
      says(powers(['Alarm: Silent', 'Globe of Daylight'])).startsWith('The book names this class\'s spells outright'),
      says(powers(['Alarm: Silent', 'Globe of Daylight'])));

    const review = (names) => (wizard ? wizard.reviewSpellSections(names.map((n) => {
      const sp = catalog.find((x) => x.name === n);
      return { type: 'spell', name: n, level: sp.level, cost: sp.ppe };
    })) : '');
    const wardReview = review(['Alarm: Silent', 'Condition: Agony']);
    check('Review: the same symbols are headed "Ward Symbols", with no "L0"',
      JSON.stringify(heads(wardReview)) === '["Ward Symbols (2)"]' && !/L0/.test(wardReview)
        && /Alarm: Silent <span class="muted">1 P.P.E.<\/span>/.test(wardReview), text(wardReview));
    const mixed = review(['Air: Cloud of Steam', 'Globe of Daylight', 'Circle of Power', 'Ritual: Old Rite']);
    check('and a mixed list is one heading per tradition, general spells first, as the sheet orders them',
      JSON.stringify(heads(mixed)) === '["Spells (2)","Circles (1)","Warlock Elemental (1)"]', JSON.stringify(heads(mixed)));
    check('levels stay wherever a tradition has them, a general level 0 included',
      /Globe of Daylight <span class="muted">L1 · 2 P.P.E.<\/span>/.test(mixed)
        && /Ritual: Old Rite <span class="muted">L0 · 5 P.P.E.<\/span>/.test(mixed)
        && /Air: Cloud of Steam <span class="muted">L1 · 4 P.P.E.<\/span>/.test(mixed)
        && /Circle of Power <span class="muted">10 P.P.E.<\/span>/.test(mixed), text(mixed));

    // The codex. Every fold is opened so the families inside the ward fold
    // are drawn too: they count by the same noun as their tradition.
    const codex = readFileSync(appPath('codex.js'), 'utf8');
    const listBody = functionBody(codex, 'function spellListHtml(');
    check('the codex\'s spell list can be cut out of codex.js', !!listBody);
    const C = { filter: '', focus: null, sort: '', traditionClasses: {},
      folds: new Set(['ward', 'ward/alarm', 'ward/condition', 'warlock']) };
    const folds = listBody ? [...new Function('S', 'SpellTraditions', 'escHtml', 'entry', 'heldBy',
      listBody + '\n}\nreturn spellListHtml;')(C, T, (x) => String(x ?? ''), () => '', () => [])(
      { id: 'spells', key: (r) => r.name }, catalog)
      .matchAll(/codex-fold-name">([^<]*)[\s\S]*?codex-fold-n">([^<]*)</g)].map((m) => `${m[1]}: ${m[2]}`) : [];
    check('the codex counts a ward fold, and each family in it, in symbols; every other tradition in spells',
      JSON.stringify(folds) === JSON.stringify(['Circles: 1 spell', 'Mixed: 2 spells', 'Ward Symbols: 2 symbols',
        'Alarm: 1 symbol', 'Condition: 1 symbol', 'Warlock Elemental: 1 spell']), JSON.stringify(folds));
    // The list of nine is the data's, so neither page may carry a copy of it.
    check('neither page names a level-0 tradition of its own',
      ![app, codex].some((src) => /'(spellsong|demonic-curse|african-witch|nazca)'/.test(src)),
      'app.js or codex.js lists traditions by slug; ask SpellTraditions.unleveled');
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

    // The trap this repo has been bitten by before: Access answers with HTML. A
    // replay that got an answer with no event id in it is not counted as sent.
    check('a replay that lands on the login page is not counted as sent',
      /res\.event_id == null/.test(sheet),
      'an expired Access session silently eats the queue');

    // NO STATUS IS NOT ALWAYS NO NETWORK. api() throws a sign-in page as a
    // statusless `notData`, and the counter said "waiting for the network" for
    // it with the browser online. The reason is read off the error by the
    // sheet's own function, run here rather than matched as text.
    const whySrc = sheet.match(/function whyUnsent\(err\) \{[\s\S]*?\n\}/);
    const why = (onLine, err) => (whySrc
      ? new Function('navigator', whySrc[0] + '; return whyUnsent;')({ onLine })(err) : 'no whyUnsent');
    check('a page where data was expected reads as signed out, online or not',
      why(true, { notData: true }) === 'signin' && why(false, { notData: true }) === 'signin',
      JSON.stringify([why(true, { notData: true }), why(false, { notData: true })]));
    check('a failed request while the browser is online is the server, not the network',
      why(true, {}) === 'server', JSON.stringify(why(true, {})));
    check('and only a browser that says it is offline waits for the network',
      why(false, {}) === null, JSON.stringify(why(false, {})));
    const told = sheet.match(/err\.status === undefined && await queueChange\([\s\S]*?\n\s+renderQueueState\(err\);/g) || [];
    check('every queueing press hands the counter its error',
      told.length === queueCalls.length, `${told.length} of ${queueCalls.length} queueing sites pass err`);
    check('and so does the replay',
      /if \(!refusedOnMerit\(err\)\) \{ renderQueueState\(err\); return; \}/.test(sheet),
      'the flush does not say why an entry is still waiting');

    // THE AUTOSAVE LINE HAS THE SAME THREE REASONS AND DIFFERENT ADVICE. A
    // typed edit is not in the queue, so it does not survive the reload the
    // counter recommends. Run, not matched, with the sheet's own function.
    const autoSrc = sheet.match(/function autosaveText\(\) \{[\s\S]*?\n\}/);
    const autoLine = (detail) => (autoSrc
      ? new Function('AS', 'escHtml', 'AS_LABELS', autoSrc[0] + '; return autosaveText();')(
        { state: 'offline', detail }, (x) => x, {}) : 'no autosaveText');
    check('an unsaved edit behind a sign-in page says to sign in from another tab',
      /signed out/.test(autoLine('signin')) && /another tab/.test(autoLine('signin')), autoLine('signin'));
    check('and never to reload, which would lose what was typed',
      !/reload/i.test(autoLine('signin')) && !/reload/i.test(autoLine('server')),
      autoLine('signin') + ' | ' + autoLine('server'));
    check('a server that is not answering is not called "no connection"',
      /server is not answering/.test(autoLine('server')) && !/no connection/.test(autoLine('server')), autoLine('server'));
    check('and offline still says no connection', /no connection/.test(autoLine('')), autoLine(''));
    const offlineSets = sheet.match(/setAutosave\('offline'[^)]*\)?\)/g) || [];
    check('every save that got no answer hands the line its reason',
      offlineSets.length > 0 && offlineSets.every((c) => /whyUnsent\(/.test(c)), offlineSets.join(' ; '));

    // A STATUS IS NOT ALWAYS A VERDICT ON THE CHANGE. The replay removed an
    // entry for any status at all, so a 503 while the queue drained lost a
    // change the player had made, silently. Run, not matched: the question is
    // which statuses the sheet's own function calls a refusal.
    const meritSrc = sheet.match(/function refusedOnMerit\(err\) \{[\s\S]*?\n\}/);
    const refused = (err) => (meritSrc
      ? new Function(meritSrc[0] + '; return refusedOnMerit;')()(err) : 'no refusedOnMerit');
    const lost = [503, 429, 500, 502, 504, 408, 522].filter((st) => refused({ status: st }) !== false);
    check('a replay answered 503 or 429 keeps its entry: nothing judged the change',
      lost.length === 0, 'treated as a refusal, so the entry is dropped: ' + lost.join(', '));
    const stuck = [400, 401, 403, 404, 409, 422].filter((st) => refused({ status: st }) !== true);
    check('and one the route itself refused still leaves the queue',
      stuck.length === 0, 'kept forever, blocking everything behind it: ' + stuck.join(', '));
    check('no answer at all is not a refusal either', refused({}) === false && refused({ notData: true }) === false,
      JSON.stringify([refused({}), refused({ notData: true })]));
    check('the replay removes an entry only behind that test',
      /if \(!refusedOnMerit\(err\)\) \{[^\n]*\n(?:\s*\/\/[^\n]*\n)*\s*await playQueue\.remove\(e\.seq\);\s*continue;/.test(sheet),
      'the catch in flushOnce drops an entry without asking whether it was refused');
    check('and an answered 503 is the server, even from a browser that says it is offline',
      why(false, { status: 503 }) === 'server' && why(true, { status: 429 }) === 'server',
      JSON.stringify([why(false, { status: 503 }), why(true, { status: 429 })]));
    check('each reason has its own words',
      /C\.unsent === 'signin' \? `\$\{waiting\} — you are signed out/.test(sheet)
        && /C\.unsent === 'server' \? `\$\{waiting\} — the server is not answering/.test(sheet)
        && /`\$\{waiting\} for the network`/.test(sheet),
      'the counter says one thing for every kind of silence');

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

  // ---------- render() rebuilds the page, and took half-typed text with it ----------
  // Autosave carries the fields it owns across a render (holdTypedEdits). Every
  // other input was DOM-only: reproduced on a local sheet on 2026-10-11, one
  // keystroke in the inventory filter emptied the journal draft, the add-item
  // form, the XP field, a grant's name and reason and the level-up panel's
  // numbers, and choosing a skill at level-up cleared the spell chosen before
  // it. The sheet now reads those off the page before the rebuild and puts
  // them back after it.
  //
  // RUN, not matched: the sheet's own three functions over stand-in controls,
  // with the rebuild played by swapping in a fresh set. What is matched as text
  // is only that render() calls them on either side of the rebuild, and that a
  // handler which sent a draft drops it - otherwise its own success puts the
  // sent text back in the box.
  section('A redraw keeps what was typed');
  {
    const sheet = readFileSync(appPath('sheet.js'), 'utf8').replace(/\r\n/g, '\n');
    const block = sheet.match(/const DRAFT_ELSEWHERE = [\s\S]*?\nfunction dropDrafts\(ids\) \{[\s\S]*?\n\}/);
    const text = (id, value = '', o = {}) => ({ id, type: 'text', tagName: 'INPUT', value, defaultValue: value, ...o });
    const pick = (id, values) => ({ id, type: 'select-one', tagName: 'SELECT', value: values[0],
      options: values.map((v) => ({ value: v, defaultSelected: false })) });
    const tick = (id) => ({ id, type: 'checkbox', tagName: 'INPUT', checked: false, defaultChecked: false });
    const SPELLS = ['', 'Armor of Ithan', 'Globe of Daylight'];
    const fresh = (spells = SPELLS) => [
      text('j-body', '', { tagName: 'TEXTAREA', type: 'textarea' }), text('add-name'), text('add-qty', '1'),
      tick('add-log'), text('xp-delta'), text('grant-reason'), text('lu-hp_max', '44'),
      pick('lu-power-spell-7-0-0', spells), pick('claim-power-psionic-3-0-0', ['', 'Mind Block']),
      pick('add-vessel', ['', 'black-galleon']),
      // Owned by something else, and so left to it.
      text('stat-hp', '12'), text('bio-age', '', { dataset: { sec: 'bio' } }),
      pick('lu-pick-0', ['', 'Barter', 'Cryptography']), text('lu-lang-0'),
      text('inv-filter'), text('lu-pick-filter'),
    ];
    const TYPED = { 'j-body': 'half a session', 'add-name': 'rope', 'add-qty': '3', 'xp-delta': '250',
      'grant-reason': 'saved the village', 'lu-hp_max': '47', 'lu-power-spell-7-0-0': 'Globe of Daylight',
      'claim-power-psionic-3-0-0': 'Mind Block', 'add-vessel': 'black-galleon' };
    const OWNED = { 'stat-hp': '9', 'bio-age': '31', 'lu-pick-0': 'Barter', 'lu-lang-0': 'Dragonese',
      'inv-filter': 'ro', 'lu-pick-filter': 'cr' };
    let page = [];
    let fills = 0;
    const at = (id) => page.find((el) => el.id === id) || null;
    const fns = block ? new Function('document', '$', 'autosaveKey', 'fillVesselPicker', 'syncGmPowerName',
      block[0] + '; return { heldDrafts, restoreDrafts, dropDrafts };')(
      { querySelectorAll: () => page }, at, (el) => el.dataset?.sec || null, () => { fills++; }, () => {}) : null;
    check('the sheet has its three draft functions', !!fns, 'no DRAFT_ELSEWHERE … dropDrafts block in sheet.js');
    const type = () => {
      for (const [id, v] of Object.entries({ ...TYPED, ...OWNED })) at(id).value = v;
      at('add-log').checked = true;
    };
    // One render: read, rebuild, put back.
    const redraw = (next) => { const held = fns.heldDrafts(); page = next; fns.restoreDrafts(held); return held; };

    if (fns) {
      page = fresh();
      check('an untouched page carries nothing across', fns.heldDrafts().length === 0, JSON.stringify(fns.heldDrafts()));

      type();
      redraw(fresh());
      const gone = Object.entries(TYPED).filter(([id, v]) => at(id).value !== v).map(([id]) => id);
      check('a redraw keeps the journal draft, the add-item form, the XP, the grant and the level-up fields',
        gone.length === 0 && at('add-log').checked === true,
        'emptied by a render: ' + [...gone, ...(at('add-log').checked ? [] : ['add-log'])].join(', '));
      const taken = Object.keys(OWNED).filter((id) => at(id).value !== fresh().find((el) => el.id === id).value);
      check('and leaves alone what autosave, a picker or a filter owns',
        taken.length === 0, 'written over what render() drew from C: ' + taken.join(', '));
      check('the vessel picker is refilled before its choice is put back', fills === 1, fills + ' fills');

      page = fresh(); type();
      redraw(fresh(['', 'Armor of Ithan']));
      check('a select that no longer offers the choice is left as drawn',
        at('lu-power-spell-7-0-0').value === '', JSON.stringify(at('lu-power-spell-7-0-0').value));

      page = fresh(); type();
      let threw = null;
      try { redraw(fresh().filter((el) => !/^lu-/.test(el.id))); } catch (err) { threw = err.message; }
      check('a control that left the page takes its draft with it', threw === null && at('j-body').value === 'half a session',
        threw || 'the journal draft went with the level-up panel');

      page = fresh(); type();
      fns.dropDrafts(/^(j-|add-log$)/);
      const left = fns.heldDrafts().map(([id]) => id);
      check('a dropped draft is not carried, and the others still are',
        !left.includes('j-body') && !left.includes('add-log') && left.includes('add-name') && at('j-body').value === '',
        left.join(', '));
    }

    check('render() reads the drafts before anything else',
      /function render\(\) \{\n  const drafts = heldDrafts\(\);/.test(sheet), 'render() does not start by reading them');
    const body = sheet.slice(sheet.indexOf('function render() {'));
    const built = body.indexOf("$('app').innerHTML = `"), back = body.indexOf('restoreDrafts(drafts);');
    check('and puts them back after the rebuild, before the page is measured',
      built > 0 && back > built && back < body.indexOf('stackColumns('), `rebuild at ${built}, restore at ${back}`);
    check('a logged XP figure does not come back',
      /jsonReq\('POST', \{ delta \}\)\);\n\s+dropDrafts\(\/\^xp-delta\$\/\);/.test(sheet), 'logXp leaves its own field to be restored');
    check('nor a saved journal entry',
      /dropDrafts\(\/\^j-\/\);\n\s+await load\(\);/.test(sheet), 'addJournal reloads with its draft still held');
    check('nor an item that was added with a journal line',
      /dropDrafts\(\/\^add-\(slug\|name\|qty\|notes\|log\)\$\/\);\n\s+await load\(\);/.test(sheet),
      'addItem reloads with the form still filled');
  }

  // ---------- A refused save keeps what was typed since ----------
  // A save answered 409 re-reads the character, and where nobody else changed
  // the fields it retries against the new version. Any play event moves the
  // version, so this is the ordinary path at a table, not a rare one. The
  // retry cleared every key it was sending - including one typed into again
  // while the refused request or the re-read was in flight. The older text was
  // stored, the line said "All changes saved", the newer text stayed on screen
  // unsent, and the next redraw took it away.
  //
  // RUN, not matched: the sheet's own markDirty, saveNow and sendEdits against
  // a stand-in server whose answers can be held while something is typed.
  section('A refused save keeps what was typed since');
  {
    const sheet = readFileSync(appPath('sheet.js'), 'utf8').replace(/\r\n/g, '\n');
    const src = ['function markDirty(key, delay = AS_DELAY) {', 'async function saveNow() {',
      'async function sendEdits(keys, vals, retried = false) {'].map((head) => {
      const from = sheet.indexOf('\n' + head), to = sheet.indexOf('\n}\n', from);
      return from < 0 || to < 0 ? null : sheet.slice(from, to + 2);
    });
    check('the sheet has markDirty, saveNow and sendEdits', src.every(Boolean),
      'one of the three autosave functions is not where this looks for it');
    const clone = (v) => (v == null ? v : JSON.parse(JSON.stringify(v)));
    const same = (a, b) => JSON.stringify(a ?? null) === JSON.stringify(b ?? null);

    // One sheet: what the server holds, what is typed on the page, and hooks
    // that run while a request is held.
    const world = () => {
      const server = { updated_at: 'v1', bio: { age: '30' }, combat: {} };
      const page = { bio: { age: '30' }, combat: {} };
      const AS = { dirty: new Set(), base: {}, timer: null, busy: null, state: 'idle', conflict: null };
      const C = { canWrite: true, data: clone(server) };
      const w = { server, page, AS, C, sent: [], during: {}, fail: {} };
      let version = 1;
      // Somebody else: a play event moves the version and touches no field.
      w.moved = (fields = {}) => { Object.assign(server, clone(fields)); server.updated_at = 'v' + (++version); };
      const api = async (path, req) => {
        if (!req) {
          await w.during.read?.();
          if (w.fail.read) throw {};
          return { character: clone(server) };
        }
        const body = JSON.parse(req.body);
        const nth = w.sent.push(body);
        await w.during['patch' + nth]?.();
        if (w.fail.patch) throw w.fail.patch;
        if (body.expect_updated_at !== server.updated_at) throw { status: 409, detail: { conflict: true } };
        const { expect_updated_at: _, ...fields } = body;
        w.moved(fields);
        return { updated_at: server.updated_at };
      };
      w.fns = new Function('AS', 'C', 'id', 'AS_DELAY', 'api', 'jsonReq', 'pendingValues', 'applyToData', 'paintPool',
        'setAutosave', 'scheduleAutosave', 'holdConflict', 'cloneValue', 'sameValue', 'errorDetails', 'whyUnsent',
        src.join('\n') + '; return { markDirty, saveNow };')(
        AS, C, 3, 1500, api, (method, body) => ({ method, body: JSON.stringify(body) }),
        (keys) => Object.fromEntries(keys.map((k) => [k, clone(page[k])])),
        (vals) => { Object.assign(C.data, clone(vals)); }, () => {},
        (state) => { AS.state = state; }, () => {},
        (fields) => { AS.conflict = { fields }; AS.state = 'conflict'; }, clone, same, () => [], () => 'server');
      w.type = (key, field, v) => { page[key][field] = v; w.fns.markDirty(key); };
      return w;
    };
    const dirty = (w) => [...w.AS.dirty].sort().join(',');

    if (src.every(Boolean)) {
      // The table moved the version; the save is refused, re-read and retried.
      let w = world();
      w.moved(); w.type('bio', 'age', '31');
      let ok = await w.fns.saveNow();
      check('a save refused only for its version is retried and lands',
        ok === true && w.server.bio.age === '31' && w.sent.length === 2 && dirty(w) === '' && w.AS.state === 'saved',
        JSON.stringify({ ok, stored: w.server.bio, sent: w.sent.length, dirty: dirty(w), state: w.AS.state }));

      // Typed into again while the refused request was in flight.
      for (const [when, label] of [['patch1', 'while the refused request was in flight'], ['read', 'during the re-read']]) {
        w = world();
        w.moved(); w.type('bio', 'age', '31');
        w.during[when] = () => { w.type('bio', 'age', '317'); w.type('combat', 'strike', '5'); };
        ok = await w.fns.saveNow();
        check(`a field typed into again ${label} is still unsaved after the retry`,
          ok === false && dirty(w) === 'bio,combat' && w.AS.state === 'pending',
          JSON.stringify({ ok, dirty: dirty(w), state: w.AS.state, stored: w.server.bio }));
        delete w.during[when];
        ok = await w.fns.saveNow();
        check('and the next save sends it',
          ok === true && w.server.bio.age === '317' && w.server.combat.strike === '5' && w.AS.state === 'saved',
          JSON.stringify({ ok, stored: [w.server.bio, w.server.combat], onScreen: w.page.bio, state: w.AS.state }));
      }

      // Every way of giving up leaves the keys unsent, and says so.
      w = world();
      w.moved({ bio: { age: '40' } }); w.type('bio', 'age', '31');
      ok = await w.fns.saveNow();
      check('a field somebody else changed is not retried: it is held and asked about',
        ok === false && dirty(w) === 'bio' && w.AS.state === 'conflict' && w.server.bio.age === '40' && w.sent.length === 1,
        JSON.stringify({ ok, dirty: dirty(w), state: w.AS.state, stored: w.server.bio, sent: w.sent.length }));

      w = world();
      w.moved(); w.type('bio', 'age', '31'); w.fail.read = true;
      ok = await w.fns.saveNow();
      check('a re-read that never arrives leaves the edit unsent',
        ok === false && dirty(w) === 'bio' && w.AS.state === 'offline', JSON.stringify({ ok, dirty: dirty(w), state: w.AS.state }));

      w = world();
      w.moved(); w.type('bio', 'age', '31');
      w.during.patch2 = () => { w.moved(); };
      ok = await w.fns.saveNow();
      check('a retry refused in its turn leaves the edit unsent',
        ok === false && dirty(w) === 'bio' && w.AS.state === 'error' && w.sent.length === 2,
        JSON.stringify({ ok, dirty: dirty(w), state: w.AS.state, sent: w.sent.length }));

      for (const [err, state] of [[{ status: 500, message: 'boom' }, 'error'], [{}, 'offline']]) {
        w = world();
        w.type('bio', 'age', '31'); w.fail.patch = err;
        ok = await w.fns.saveNow();
        check(`a save that fails (${state}) leaves the edit unsent`,
          ok === false && dirty(w) === 'bio' && w.AS.state === state, JSON.stringify({ ok, dirty: dirty(w), state: w.AS.state }));
      }
    }
  }

  // ---------- A form switch waits for what was typed ----------
  // A two-form character (a Nightbane's Facade and Morphus) draws the second
  // form's combat and saves read-only, and its S.D.C. and hit point cards hold
  // THAT form's numbers under the same ids. setForm saved what was typed
  // before switching and did not look at the answer. With the save failed or
  // held for a Keep mine / Use theirs choice, the fields stayed unsent and the
  // page under them changed: the retry read the Morphus hit points out of
  // #stat-hp and stored them as the first form's, skipped the combat section
  // because its inputs were gone, and said "All changes saved".
  //
  // RUN, not matched: the sheet's own setForm, markDirty, saveNow and sendEdits
  // over a stand-in page that reads as the form showing, the way the real one
  // does, and a stand-in server whose answers can fail.
  section('A form switch waits for what was typed');
  {
    const sheet = readFileSync(appPath('sheet.js'), 'utf8').replace(/\r\n/g, '\n');
    const src = ['async function setForm(which) {', 'function markDirty(key, delay = AS_DELAY) {',
      'async function saveNow() {', 'async function sendEdits(keys, vals, retried = false) {'].map((head) => {
      const from = sheet.indexOf('\n' + head), to = sheet.indexOf('\n}\n', from);
      return from < 0 || to < 0 ? null : sheet.slice(from, to + 2);
    });
    check('the sheet has setForm, markDirty, saveNow and sendEdits', src.every(Boolean),
      'one of the four functions is not where this looks for it');
    const clone = (v) => (v == null ? v : JSON.parse(JSON.stringify(v)));
    const same = (a, b) => JSON.stringify(a ?? null) === JSON.stringify(b ?? null);

    const world = (canWrite = true) => {
      const server = { updated_at: 'v1', hp_current: 20, combat: {}, second_form: { active: 'first', hp_current: 51 } };
      // What the first form's inputs hold. The second form's card holds 51.
      const typed = { hp_current: 20, combat: {} };
      const AS = { dirty: new Set(), base: {}, timer: null, busy: null, state: 'idle', conflict: null };
      const C = { canWrite, data: { updated_at: 'v1', hp_current: 20, combat: {} },
        secondForm: { active: 'first', hp_current: 51 } };
      const w = { server, typed, AS, C, sent: [], fail: {}, renders: 0, flashes: [] };
      let version = 1;
      w.moved = (fields = {}) => { Object.assign(server, clone(fields)); server.updated_at = 'v' + (++version); };
      const api = async (path, req) => {
        if (!req) return { character: clone(server) };
        const body = JSON.parse(req.body);
        w.sent.push(body);
        if (w.fail.patch) throw w.fail.patch;
        if (body.second_form) {
          Object.assign(server.second_form, body.second_form);
          w.moved();
          return { updated_at: server.updated_at };
        }
        if (body.expect_updated_at !== server.updated_at) throw { status: 409, detail: { conflict: true } };
        const { expect_updated_at: _, ...fields } = body;
        w.moved(fields);
        return { updated_at: server.updated_at };
      };
      // The page as pendingValues finds it: no combat inputs while the second
      // form shows, and #stat-hp holding whichever form's hit points are drawn.
      const pendingValues = (keys) => {
        const second = C.secondForm.active === 'second';
        const out = {};
        for (const k of keys) {
          if (k === 'combat') { if (!second) out.combat = clone(typed.combat); }
          else out[k] = second ? C.secondForm.hp_current : typed[k];
        }
        return out;
      };
      w.fns = new Function('AS', 'C', 'id', 'AS_DELAY', 'api', 'jsonReq', 'pendingValues', 'applyToData', 'paintPool',
        'setAutosave', 'scheduleAutosave', 'holdConflict', 'cloneValue', 'sameValue', 'errorDetails', 'whyUnsent',
        'render', 'flash',
        src.join('\n') + '; return { setForm, markDirty, saveNow };')(
        AS, C, 11, 1500, api, (method, body) => ({ method, body: JSON.stringify(body) }),
        pendingValues, (vals) => { Object.assign(C.data, clone(vals)); }, () => {},
        (state) => { AS.state = state; }, () => {},
        (fields) => { AS.conflict = { fields }; AS.state = 'conflict'; }, clone, same, () => [], () => 'server',
        () => { w.renders++; }, (text, isError) => { w.flashes.push([text, !!isError]); });
      w.type = () => {
        typed.hp_current = 11; w.fns.markDirty('hp_current');
        typed.combat = { strike: '7' }; w.fns.markDirty('combat');
      };
      w.formSent = () => w.sent.filter((b) => b.second_form).length;
      w.see = () => JSON.stringify({ form: C.secondForm.active, renders: w.renders, sent: w.sent, dirty: [...AS.dirty],
        state: AS.state, hp: server.hp_current, combat: server.combat, flashes: w.flashes });
      return w;
    };

    if (src.every(Boolean)) {
      let w = world();
      await w.fns.setForm('second');
      check('with nothing typed the form switches, is drawn and is saved',
        w.C.secondForm.active === 'second' && w.renders === 1 && w.server.second_form.active === 'second'
          && w.sent.length === 1 && w.flashes.length === 0, w.see());
      await w.fns.setForm('second'); await w.fns.setForm('third');
      check('the form already showing, or one that does not exist, does nothing',
        w.renders === 1 && w.sent.length === 1 && w.C.secondForm.active === 'second', w.see());

      w = world();
      w.type();
      await w.fns.setForm('second');
      check('what was typed is saved first, and then the form switches',
        w.server.hp_current === 11 && w.server.combat.strike === '7' && w.C.secondForm.active === 'second'
          && w.renders === 1 && w.formSent() === 1 && w.sent.length === 2, w.see());

      // The save never arrives.
      w = world();
      w.type(); w.fail.patch = {};
      await w.fns.setForm('second');
      check('a save that fails leaves the first form on screen',
        w.C.secondForm.active === 'first' && w.renders === 0 && w.formSent() === 0, w.see());
      check('and says why it did not switch',
        w.flashes.length === 1 && w.flashes[0][1] === true && /^Not switched\b.*\bsaved/.test(w.flashes[0][0]), w.see());
      check('and the edit is still unsent', [...w.AS.dirty].sort().join(',') === 'combat,hp_current', w.see());
      w.fail.patch = null;
      let ok = await w.fns.saveNow();
      check('the retry then stores the first form\'s own numbers, the typed override with them',
        ok === true && w.server.hp_current === 11 && w.server.combat.strike === '7' && w.AS.state === 'saved', w.see());
      await w.fns.setForm('second');
      check('and the next press switches',
        w.C.secondForm.active === 'second' && w.renders === 1 && w.server.second_form.active === 'second'
          && w.server.hp_current === 11, w.see());

      // Refused on its merits: an error line, not a retry.
      w = world();
      w.type(); w.fail.patch = { status: 500, message: 'boom' };
      await w.fns.setForm('second');
      check('a save the server refuses leaves the first form on screen too',
        w.C.secondForm.active === 'first' && w.renders === 0 && w.formSent() === 0 && w.flashes.length === 1, w.see());

      // Somebody else changed the same field: held for Keep mine / Use theirs.
      w = world();
      w.moved({ hp_current: 15 }); w.type();
      await w.fns.setForm('second');
      check('an edit held for a Keep mine / Use theirs choice does not switch either',
        w.AS.state === 'conflict' && w.C.secondForm.active === 'first' && w.renders === 0 && w.formSent() === 0
          && w.server.hp_current === 15 && w.flashes.length === 1, w.see());

      // A reader flips the view and writes nothing.
      w = world(false);
      await w.fns.setForm('second');
      check('a reader switches the view without a request',
        w.C.secondForm.active === 'second' && w.renders === 1 && w.sent.length === 0 && w.flashes.length === 0, w.see());
    }
  }

  // ---------- A skill roll stops at 98 ----------
  // p.22: "there is always a margin for error". js/leveling.js caps a skill at
  // SKILL_PCT_CAP wherever one is built or levelled, and the roll did not: a
  // stored 120%, or a 90% skill with the G.M.'s +20, passed on a roll of 99.
  // Nate's ruling, 2026-10-11: the roll is capped at 98.
  //
  // RUN, not matched: the sheet's own rollSkill with the die chosen.
  section('A skill roll stops at 98');
  {
    const sheet = readFileSync(appPath('sheet.js'), 'utf8').replace(/\r\n/g, '\n');
    const from = sheet.indexOf('\nconst SKILL_PCT_CAP = ');
    const fn = sheet.indexOf('\nfunction rollSkill(name, pct) {', from);
    const to = sheet.indexOf('\n}\n', fn);
    const src = from < 0 || fn < 0 || to < 0 ? null : sheet.slice(from, to + 2);
    check('the sheet has rollSkill, with its cap stated just above it', !!src && fn - from < 1200,
      'const SKILL_PCT_CAP and function rollSkill are not where this looks for them');
    if (src) {
      const leveling = readFileSync(appPath('js/leveling.js'), 'utf8');
      const stated = /^export const SKILL_PCT_CAP = (\d+);/m.exec(leveling);
      const mine = /^const SKILL_PCT_CAP = (\d+);/m.exec(src.trimStart());
      check('the sheet\'s cap is the one js/leveling.js states', !!stated && !!mine && stated[1] === mine[1] && stated[1] === '98',
        JSON.stringify({ leveling: stated?.[1], sheet: mine?.[1] }));

      // One roll: the die face chosen, the modifier waiting, what was recorded.
      const rollOnce = (pct, die, mod = 0) => {
        let seen = null;
        new Function('Math', 'takeRollMod', 'recordRoll', src + '; return rollSkill;')(
          { random: () => (die - 0.5) / 100, floor: Math.floor, min: Math.min, max: Math.max },
          () => mod, (kind, name, r) => { seen = { kind, name, ...r }; })('Climbing', pct);
        return seen;
      };
      const cases = [
        // pct, die, mod, target, ok
        [60, 60, 0, 60, true], [60, 61, 0, 60, false],
        [98, 98, 0, 98, true], [98, 99, 0, 98, false],
        [120, 98, 0, 98, true], [120, 99, 0, 98, false], [120, 100, 0, 98, false],
        [90, 99, 20, 98, false], [90, 98, 20, 98, true],
        [120, 78, -20, 78, true], [120, 79, -20, 78, false],
        [50, 30, -20, 30, true], [50, 31, -20, 30, false],
      ];
      for (const [pct, die, mod, target, ok] of cases) {
        const r = rollOnce(pct, die, mod);
        check(`a ${pct}% skill${mod ? ` at ${mod > 0 ? '+' : ''}${mod}%` : ''} rolling ${die} ${ok ? 'passes' : 'fails'} against ${target}`,
          !!r && r.kind === 'skill' && r.die === 100 && r.roll === die && r.target === target && r.ok === ok,
          JSON.stringify(r));
      }
    }
  }

  // ---------- The Hit to picker follows the armour list ----------
  // The picker beside Damage names an armour by its place in the stored list,
  // and it was drawn by render() and by a hit and by nothing else. Armour is
  // edited in place and saved by autosave, with no render. So a sheet whose
  // first armour had just been typed in offered no picker until a reload; one
  // whose armour had been removed still offered it, and choosing it took the
  // points off whichever armour had moved into its place.
  //
  // And a slot with every field blanked is not stored, so the stored list was
  // one shorter than the page from there down. A hit was written onto the page
  // by the stored index: onto the blank slot. The next armour save then stored
  // the page - the hit gone from the armour that took it, and a nameless armour
  // holding the number.
  //
  // RUN, not matched: the sheet's own save path (markDirty to sendEdits), its
  // armour reader and its picker over stand-in slots and a stand-in server that
  // moves its version on a hit, as events.js does.
  section('The Hit to picker follows the armour list');
  {
    const sheet = readFileSync(appPath('sheet.js'), 'utf8').replace(/\r\n/g, '\n');
    const fn = (head) => {
      const from = sheet.indexOf('\n' + head), to = sheet.indexOf('\n}\n', from);
      return from < 0 || to < 0 ? null : sheet.slice(from, to + 2);
    };
    // From the armour helpers to the function that writes a hit onto the page.
    const from = sheet.indexOf('\nconst intOrNull = '), last = sheet.indexOf('\nfunction paintArmorInput(i) {');
    const picker = from < 0 || last < from ? null : sheet.slice(from, sheet.indexOf('\n}\n', last) + 2);
    const src = [picker, ...['function removeArmor(i) {', 'function reindexArmor() {', 'function collectSections() {',
      'function markDirty(key, delay = AS_DELAY) {', 'function pendingValues(keys) {', 'function applyToData(vals) {',
      'async function saveNow() {', 'async function sendEdits(keys, vals, retried = false) {'].map(fn)];
    check('the sheet has its armour, picker and autosave functions', src.every(Boolean),
      'one of them is not where this looks for it');
    const clone = (v) => (v == null ? v : JSON.parse(JSON.stringify(v)));
    const same = (a, b) => JSON.stringify(a ?? null) === JSON.stringify(b ?? null);
    const KEYS = ['name', 'ar', 'mdc_current', 'mdc_max', 'weight', 'cost', 'prowl'];
    // `[data-armor="1"][data-key="name"]`, read as the conditions it states.
    const matches = (el, sel) => [...sel.matchAll(/\[data-([a-z-]+)(?:="([^"]*)")?\]/g)].every(([, attr, v]) => {
      const key = attr.replace(/-(\w)/g, (_, c) => c.toUpperCase());
      return el.dataset[key] != null && (v === undefined || String(el.dataset[key]) === v);
    });

    const world = (stored = []) => {
      const server = { updated_at: 'v1', armor: clone(stored) };
      const AS = { dirty: new Set(), base: {}, timer: null, busy: null, state: 'idle', conflict: null };
      const C = { canWrite: true, hitTo: 'body', vehicles: [], data: clone(server) };
      const w = { server, AS, C, slots: [], bar: '' };
      let version = 1;
      const bump = () => { server.updated_at = 'v' + (++version); };
      const slot = (a, i) => {
        const s = { inputs: KEYS.map((key) => ({ dataset: { armor: i, key }, value: a[key] ?? '' })) };
        s.querySelectorAll = (sel) => s.inputs.filter((el) => matches(el, sel));
        s.querySelector = (sel) => s.querySelectorAll(sel)[0] || null;
        s.remove = () => { w.slots.splice(w.slots.indexOf(s), 1); };
        return s;
      };
      // What render() draws: one slot per stored armour, and the picker.
      w.draw = () => { w.slots = (C.data.armor || []).map(slot); w.bar = fns.hitToHtml(); };
      const inputs = () => w.slots.flatMap((s) => s.inputs);
      const doc = {
        querySelectorAll: (sel) => (/data-armor/.test(sel) ? inputs().filter((el) => matches(el, sel)) : []),
        querySelector: (sel) => {
          if (/data-armor/.test(sel)) return inputs().find((el) => matches(el, sel)) || null;
          // The Damage button the picker sits in front of.
          if (/dmg/.test(sel)) return { insertAdjacentHTML: (where, html) => { if (where === 'beforebegin') w.bar = html; } };
          return null;
        },
      };
      const $ = (elId) => {
        if (elId === 'armor-list') return { querySelectorAll: () => [...w.slots] };
        if (elId === 'play-hit-to') return w.bar ? { set outerHTML(html) { w.bar = html; } } : null;
        return null;
      };
      const api = async (path, req) => {
        if (!req) return { character: clone(server) };
        const body = JSON.parse(req.body);
        if (body.expect_updated_at !== server.updated_at) throw { status: 409, detail: { conflict: true } };
        const { expect_updated_at: _, ...fields } = body;
        Object.assign(server, clone(fields)); bump();
        return { updated_at: server.updated_at };
      };
      const fns = new Function('AS', 'C', 'id', 'AS_DELAY', 'AS_SECTIONS', 'document', '$', 'api', 'jsonReq', 'escHtml',
        'poolMax', 'paintPool', 'setAutosave', 'scheduleAutosave', 'holdConflict', 'cloneValue', 'sameValue', 'errorDetails', 'whyUnsent',
        src.join('\n') + '; return { markDirty, saveNow, removeArmor, hitToHtml, paintArmorInput };')(
        AS, C, 3, 1500, ['bio', 'combat', 'saves', 'armor'], doc, $, api,
        (method, body) => ({ method, body: JSON.stringify(body) }), (s) => String(s),
        () => null, () => {}, (state) => { AS.state = state; }, () => {},
        (fields) => { AS.conflict = { fields }; AS.state = 'conflict'; }, clone, same, () => [], () => 'server');
      w.fns = fns;
      w.add = (a) => { w.slots.push(slot({}, w.slots.length)); for (const [k, v] of Object.entries(a)) w.type(w.slots.length - 1, k, v); };
      w.type = (i, key, v) => { w.slots[i].inputs.find((el) => el.dataset.key === key).value = v; fns.markDirty('armor'); };
      w.blank = (i) => { for (const key of KEYS) w.type(i, key, ''); };
      w.options = () => [...w.bar.matchAll(/<option value="([^"]*)"( selected)?>([^<]*)<\/option>/g)]
        .map(([, value, on, label]) => (on ? '>' : '') + value + ' ' + label.trim());
      // Damage on whatever the picker holds: one field of one stored entry by
      // its index, the version moved, and the number written onto the page.
      w.hit = (amt) => {
        const i = Number(String(C.hitTo).split(':')[1]);
        const a = C.data.armor[i];
        if (!a || !server.armor[i]) return null;
        const to = String((parseInt(a.mdc_current, 10) || parseInt(a.mdc_max, 10)) - amt);
        a.mdc_current = to; server.armor[i].mdc_current = to; bump();
        fns.paintArmorInput(i);
        return server.armor[i].name;
      };
      w.onPage = () => w.slots.map((s) => s.inputs[0].value + ':' + s.inputs[2].value).join(' | ');
      w.held = () => server.armor.map((a) => a.name + ':' + a.mdc_current).join(' | ');
      w.draw();
      return w;
    };
    const ALPHA = { name: 'Alpha', mdc_max: '100' }, BRAVO = { name: 'Bravo', mdc_max: '200' }, CHARLIE = { name: 'Charlie', mdc_max: '300' };
    const full = (a) => ({ ...Object.fromEntries(KEYS.map((k) => [k, ''])), ...a });

    if (src.every(Boolean)) {
      let w = world();
      check('a sheet with no armour draws no picker', w.bar === '' && w.C.hitTo === 'body', w.bar);
      w.add(ALPHA); w.add(BRAVO);
      let ok = await w.fns.saveNow();
      check('armour typed in and saved is offered at once, without a redraw',
        ok === true && w.options().join(', ') === '>body Hit to: body, armor:0 Alpha (100/100), armor:1 Bravo (200/200)',
        JSON.stringify({ ok, picker: w.options(), stored: w.held() }));

      w = world([ALPHA, BRAVO, CHARLIE].map(full));
      w.C.hitTo = 'armor:1'; w.draw();
      w.type(1, 'mdc_max', '250');
      await w.fns.saveNow();
      check('an edit to the chosen armour keeps the choice and redraws its numbers',
        w.C.hitTo === 'armor:1' && w.options().includes('>armor:1 Bravo (250/250)'), JSON.stringify(w.options()));

      w.fns.removeArmor(0);
      await w.fns.saveNow();
      check('a removed armour is no longer offered',
        w.options().join(', ') === '>body Hit to: body, armor:0 Bravo (250/250), armor:1 Charlie (300/300)',
        JSON.stringify(w.options()));
      check('and the choice does not pass to the armour that took its place',
        w.C.hitTo === 'body', `chosen Bravo at armor:1, which is now ${w.C.data.armor[1]?.name}; the picker holds ${w.C.hitTo}`);

      w.fns.removeArmor(0); w.fns.removeArmor(0);
      await w.fns.saveNow();
      check('the last armour removed takes the picker with it', w.bar === '' && w.C.hitTo === 'body', w.bar);

      // Three suits of one name: the place still holds that name afterwards.
      w = world([{ name: 'Plate', mdc_max: '50' }, { name: 'Plate', mdc_max: '60' }, { name: 'Plate', mdc_max: '70' }].map(full));
      w.C.hitTo = 'armor:1'; w.draw();
      w.fns.removeArmor(0);
      await w.fns.saveNow();
      check('nor to a namesake, when a shorter list is all that says the places moved',
        w.C.hitTo === 'body', `the picker holds ${w.C.hitTo}: ${JSON.stringify(w.options())}`);

      // The first slot blanked by hand, the second still filled.
      w = world([BRAVO, CHARLIE].map(full));
      w.blank(0);
      await w.fns.saveNow();
      check('a slot blanked by hand is not stored', w.held() === 'Charlie:' && w.slots.length === 2, w.held());
      w.C.hitTo = w.options().find((o) => /Charlie/.test(o))?.split(' ')[0];
      const took = w.hit(10);
      check('a hit on the armour below it is written on that armour\'s slot',
        took === 'Charlie' && w.onPage() === ': | Charlie:290', JSON.stringify({ took, page: w.onPage() }));
      w.type(1, 'weight', '20');
      ok = await w.fns.saveNow();
      check('and the next armour save keeps the hit where it landed',
        ok === true && w.held() === 'Charlie:290', JSON.stringify({ ok, stored: w.held(), state: w.AS.state }));
    }
  }

  // ---------- A row behind an Undo stays off the screen until the toast is done ----------
  // WRITTEN FROM A LIVE BUG (reproduced on a local server, 2026-10-11). The
  // DELETE waits six seconds behind the Undo (js/undo-toast.js), so for those
  // six seconds the server still holds the row - and every re-read of the
  // character handed it straight back. Two ways in, neither unusual: add
  // another item or vessel inside the window, or remove a second row, whose
  // toast commits the first and whose commit re-reads. The row was drawn again
  // under a toast saying it was removed, and Undo then drew it twice. The
  // server only ever held one.
  //
  // RUN, not matched: the sheet's two removers and two re-reads, and the real
  // undo-toast.js, over a stand-in server, a stand-in page and timers this
  // section fires by hand.
  section('A row behind an Undo stays off the screen');
  {
    const sheet = readFileSync(appPath('sheet.js'), 'utf8').replace(/\r\n/g, '\n');
    const toastSrc = readFileSync(join(appDir, 'js', 'undo-toast.js'), 'utf8');
    const fn = (head) => {
      const from = sheet.indexOf('\n' + head), to = sheet.indexOf('\n}\n', from);
      return from < 0 || to < 0 ? null : sheet.slice(from, to + 2);
    };
    const src = ['function removeItem(rowId) {', 'function removeVessel(vid) {',
      'async function refreshInventory() {', 'async function refreshVessels() {'].map(fn);
    check('the sheet has its two removers and its two re-reads', src.every(Boolean),
      'one of them is not where this looks for it');
    // The list of rows waiting behind an Undo, and the filter every re-read
    // goes through. Absent, the rest still runs - and says what the bug did.
    // And the vessel edits a re-read waits behind: none are on their way here.
    const waiting = (fn('const removing = ') || '') + (/\nlet vesselSends = [^\n]*\n/.exec(sheet)?.[0] || '');
    const clone = (v) => JSON.parse(JSON.stringify(v));
    const settle = () => new Promise((r) => setImmediate(r));

    const world = (items, vehicles) => {
      const server = { items: clone(items), vehicles: clone(vehicles) };
      const C = { items: clone(items), vehicles: clone(vehicles) };
      const w = { server, C, page: { 'inv-rows': { innerHTML: '' }, 'vessel-list': { innerHTML: '' } }, refuse: false, deletes: [] };
      const api = async (path, req) => {
        if (!req) return clone(server);
        const [, kind, rowId] = /\/(items|vehicles)\/(\d+)$/.exec(path);
        if (w.refuse) throw new Error('refused');
        w.deletes.push(kind + ' ' + rowId);
        server[kind] = server[kind].filter((x) => x.id !== +rowId);
        return { ok: true };
      };
      // undo-toast.js, with a page it can draw on and timers held here.
      const timers = new Map(); let nextTimer = 0; const on = {};
      const box = { hidden: true, innerHTML: '', setAttribute() {} };
      const doc = {
        createElement: () => box, body: { contains: () => false, appendChild() {} },
        addEventListener: (type, h) => { on[type] = h; },
      };
      const g = { addEventListener: (type, h) => { on[type] = h; } };
      new Function('globalThis', 'document', 'setTimeout', 'clearTimeout', toastSrc)(
        g, doc, (h) => { timers.set(++nextTimer, h); return nextTimer; }, (t) => { timers.delete(t); });
      w.toast = () => (box.hidden ? null : box.innerHTML.replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ').trim());
      w.undo = () => on.click({ target: { closest: (sel) => (sel === '[data-undo-now]' && !box.hidden ? {} : null) } });
      // The six seconds running out.
      w.expire = async () => { for (const [t, h] of [...timers]) { timers.delete(t); h(); } await settle(); };
      const names = (rows) => rows.map((x) => x.name).join(',');
      w.fns = new Function('C', 'id', 'api', '$', 'undoable', 'inventoryRowsHtml', 'vesselsHtml', 'repaintPlayWeapons',
        waiting + src.join('\n') + '; return { removeItem, removeVessel, refreshInventory, refreshVessels };')(
        C, 3, api, (elId) => w.page[elId] || null, g.undoable, () => names(C.items), () => names(C.vehicles), () => {});
      w.fns.refreshInventory(); w.fns.refreshVessels();
      return w;
    };
    const rows = (...ns) => ns.map((name, i) => ({ id: i + 1, name, item_name: name, vehicle_name: name }));

    if (src.every(Boolean)) {
      for (const [what, key, el, remove, reread] of [
        ['an item', 'items', 'inv-rows', 'removeItem', 'refreshInventory'],
        ['a vessel', 'vehicles', 'vessel-list', 'removeVessel', 'refreshVessels'],
      ]) {
        const seen = (w) => w.page[el].innerHTML + ' / ' + w.C[key].map((x) => x.name).join(',');
        const held = (w) => w.server[key].map((x) => x.name).join(',');

        let w = world(rows('Alpha', 'Bravo', 'Charlie'), rows('Alpha', 'Bravo', 'Charlie'));
        await settle();
        w.fns[remove](2);
        check(`${what} removed is off the screen at once, and not yet deleted`,
          seen(w) === 'Alpha,Charlie / Alpha,Charlie' && held(w) === 'Alpha,Bravo,Charlie' && w.toast() === 'Removed Bravo. Undo',
          JSON.stringify({ seen: seen(w), held: held(w), toast: w.toast() }));
        await w.fns[reread]();
        check('a re-read inside the Undo window leaves it off',
          seen(w) === 'Alpha,Charlie / Alpha,Charlie', `the toast says "${w.toast()}" and the page shows ${seen(w)}`);
        w.undo();
        check('Undo puts it back once, where it was',
          seen(w) === 'Alpha,Bravo,Charlie / Alpha,Bravo,Charlie' && w.toast() === null, seen(w));
        await w.fns[reread]();
        await w.expire();
        check('and it stays: the next re-read draws it, and nothing was deleted',
          seen(w) === 'Alpha,Bravo,Charlie / Alpha,Bravo,Charlie' && held(w) === 'Alpha,Bravo,Charlie' && !w.deletes.length,
          JSON.stringify({ seen: seen(w), held: held(w), deletes: w.deletes }));

        // Two removals in a row. The second toast commits the first, and that
        // commit re-reads the character while the second is still only hidden.
        w = world(rows('Alpha', 'Bravo', 'Charlie'), rows('Alpha', 'Bravo', 'Charlie'));
        await settle();
        w.fns[remove](1); w.fns[remove](2);
        await settle();
        check(`a second ${what.split(' ')[1]} removed straight after stays off while the first is deleted`,
          seen(w) === 'Charlie / Charlie' && held(w) === 'Bravo,Charlie' && w.toast() === 'Removed Bravo. Undo',
          JSON.stringify({ seen: seen(w), held: held(w), toast: w.toast() }));
        w.undo();
        check('and Undo brings the second back once',
          seen(w) === 'Bravo,Charlie / Bravo,Charlie', seen(w));

        w = world(rows('Alpha', 'Bravo'), rows('Alpha', 'Bravo'));
        await settle();
        w.fns[remove](1);
        await w.fns[reread]();
        await w.expire();
        check('left alone, it is deleted when the toast runs out',
          seen(w) === 'Bravo / Bravo' && held(w) === 'Bravo' && w.deletes.length === 1,
          JSON.stringify({ seen: seen(w), held: held(w), deletes: w.deletes }));

        w = world(rows('Alpha', 'Bravo'), rows('Alpha', 'Bravo'));
        await settle();
        w.fns[remove](1);
        w.refuse = true;
        await w.expire();
        await w.fns[reread]();
        check('a refused delete puts it back, and it is still there after a re-read',
          seen(w) === 'Alpha,Bravo / Alpha,Bravo' && /Could not remove Alpha/.test(w.toast() || ''),
          JSON.stringify({ seen: seen(w), toast: w.toast() }));
      }
    }
    // load() is the third re-read, and too wide to run here: read instead that
    // nothing stores the server's rows without passing them through the filter.
    const stores = [...sheet.matchAll(/C\.(items|vehicles) = ([^;]*res\.[^;]*);/g)];
    const raw = stores.filter(([, kind, from]) => !from.startsWith(`stillHere('${kind}', res.${kind})`));
    check('every re-read of the character leaves out a row that is behind an Undo',
      stores.length === 4 && !raw.length,
      `${stores.length} stores of the server's rows (load, refreshInventory, refreshVessels: 4 expected); unfiltered: ${raw.map((m) => m[0]).join(' ') || 'none'}`);
  }

  // ---------- A vessel's M.D.C. keeps every location typed into it ----------
  // WRITTEN FROM A LIVE BUG (reproduced on a local server, 2026-10-11). The
  // column is one object and a location edit sends all of it. The handler
  // copied the object out of state, sent the copy, and wrote state when the
  // answer came - so a second location typed before the first had answered
  // copied the same stale object. The server kept the second location alone,
  // and the page went on showing both until a reload. No slow network needed:
  // two `change` events in one tick did it.
  //
  // And a request that failed left its number in the input, over a state and a
  // server that never held it.
  //
  // RUN, not matched: the sheet's own handler over stand-in inputs and a
  // stand-in server whose answers can be held or failed one by one.
  section('A vessel keeps every location typed into it');
  {
    const sheet = readFileSync(appPath('sheet.js'), 'utf8').replace(/\r\n/g, '\n');
    const fn = (head) => {
      const from = sheet.indexOf('\n' + head), to = sheet.indexOf('\n}\n', from);
      return from < 0 || to < 0 ? null : sheet.slice(from, to + 2);
    };
    const src = ['function paintVesselInput(vid, location) {', 'async function patchVesselMdc(vid, location, value) {',
      'async function vesselClash(location, typed, err) {', 'async function refreshVessels() {'].map(fn);
    check('the sheet has its vessel M.D.C. handler, its painter, its clash answer and its re-read', src.every(Boolean),
      'one of them is not where this looks for it');
    // The turn-taking the handler keeps between calls, and what it believes the
    // server holds. Absent, the rest still runs - and says what the bug did.
    const turns = (/\nlet vesselSends = [^\n]*\n/.exec(sheet)?.[0] || '')
      + (/\nconst vesselBase = [^\n]*\n/.exec(sheet)?.[0] || '');
    const clone = (v) => JSON.parse(JSON.stringify(v));
    const settle = async () => { for (let i = 0; i < 5; i++) await new Promise((r) => setImmediate(r)); };
    const LOCS = [['Head', 100], ['Arms', 180], ['Body', 450]];

    const world = (stored = {}) => {
      const server = { mdc: clone(stored) };
      const C = { vehicles: [{ id: 8, vehicle_name: 'Rig', mdc_current: clone(stored),
        locations: LOCS.map(([location, mdc]) => ({ location, mdc })) }] };
      const w = { server, C, sent: [], reads: 0, hold: {}, fail: {}, alerts: [], picker: null, inputs: [] };
      // What vesselLocationHtml draws: the stored number, or the maximum.
      w.inputs = LOCS.map(([loc, max]) => ({ dataset: { vessel: '8', loc }, value: String(stored[loc] ?? max) }));
      const doc = { querySelectorAll: (sel) => (/data-vessel="8"/.test(sel) ? w.inputs : []) };
      const own = (o, k) => Object.prototype.hasOwnProperty.call(o || {}, k);
      // A held request has not ARRIVED: the server stores it when it is let go.
      // The stand-in keeps the route's rule: one location, and only if it
      // still holds what the request says it replaces (regression.mjs asks the
      // real route the same things).
      const api = async (path, req) => {
        if (!req) {
          w.reads++;
          // A held read was TAKEN when it was asked for; it only answers late.
          const taken = clone(server.mdc);
          if (w.holdRead) { w.holdRead = false; await new Promise((r) => { w.releaseRead = r; }); }
          return { vehicles: [{ ...C.vehicles[0], mdc_current: taken }] };
        }
        const body = JSON.parse(req.body);
        const nth = w.sent.push(body);
        if (w.hold[nth]) await new Promise((r) => { w.release = r; });
        if (w.fail[nth]) throw new Error('no answer');
        const { location, mdc } = body;
        const held = own(server.mdc, location);
        const asSeen = mdc.absent ? !held : held && server.mdc[location] === mdc.from;
        const wanted = mdc.to === null ? !held : held && server.mdc[location] === mdc.to;
        if (!asSeen && !wanted) {
          throw Object.assign(new Error(location + ' was changed somewhere else since this was read'), {
            status: 409,
            detail: { conflict: true, location, mine: mdc.to, theirs: held ? server.mdc[location] : null, base: mdc.from },
          });
        }
        if (mdc.to === null) delete server.mdc[location]; else server.mdc[location] = mdc.to;
        return { ok: true };
      };
      // The redraw: every input written again from state, as vesselsHtml would.
      const redraw = () => {
        for (const el of w.inputs) {
          const max = LOCS.find(([loc]) => loc === el.dataset.loc)[1];
          el.value = String(C.vehicles[0].mdc_current?.[el.dataset.loc] ?? max);
        }
        return '';
      };
      w.fns = new Function('C', 'id', 'api', 'jsonReq', 'document', 'hasKey', 'repaintHitTo', 'alert',
        'stillHere', '$', 'vesselsHtml',
        turns + src.join('\n') + '; return { patchVesselMdc, refreshVessels };')(
        C, 3, api, (method, body) => ({ method, body: JSON.stringify(body) }), doc, own,
        // The picker's labels are drawn from state: keep what it would have read.
        () => { w.picker = JSON.stringify(C.vehicles[0].mdc_current || {}); }, (msg) => { w.alerts.push(msg); },
        (kind, rows) => rows, () => ({}), redraw);
      // Somebody else, in another browser: straight into what the server holds.
      w.elsewhere = (loc, v) => { if (v === undefined) delete server.mdc[loc]; else server.mdc[loc] = v; };
      // The input's own `change`: the value is on the page, then the handler runs.
      w.type = (loc, v) => { w.inputs.find((el) => el.dataset.loc === loc).value = v; return w.fns.patchVesselMdc(8, loc, v); };
      w.page = () => w.inputs.map((el) => el.value).join('/');
      w.state = () => JSON.stringify(C.vehicles[0].mdc_current || {});
      w.held = () => JSON.stringify(server.mdc);
      w.all = () => JSON.stringify({ page: w.page(), state: w.state(), stored: w.held(), sent: w.sent, alerts: w.alerts });
      return w;
    };

    if (src.every(Boolean)) {
      let w = world();
      w.type('Head', '11'); w.type('Arms', '22');
      await settle();
      check('two locations typed one straight after the other are both stored',
        w.held() === '{"Head":11,"Arms":22}' && w.state() === w.held() && w.page() === '11/22/450', w.all());
      check('and the Hit to picker is redrawn with them', w.picker === w.held(), `the picker last read ${w.picker}`);

      // The first request is still on its way when the second is typed.
      w = world({ Body: 400 });
      w.hold[1] = true;
      w.type('Head', '11'); w.type('Arms', '22');
      await settle();
      check('a second edit waits its turn while the first is still on its way',
        w.sent.length === 1 && w.held() === '{"Body":400}', w.all());
      w.release();
      await settle();
      check('and both arrive, in the order they were typed, with what was already stored',
        w.held() === '{"Body":400,"Head":11,"Arms":22}' && w.state() === w.held() && w.sent.length === 2, w.all());

      w = world();
      w.hold[1] = true;
      w.type('Head', '11'); w.type('Head', '12');
      await settle(); w.release(); await settle();
      check('one location typed twice ends on the second number',
        w.held() === '{"Head":12}' && w.state() === w.held() && w.page() === '12/180/450', w.all());

      w = world({ Head: 60 });
      w.type('Head', '');
      await settle();
      check('a blanked location is stored as undamaged', w.held() === '{}' && w.state() === '{}', w.all());

      // A request that fails.
      w = world();
      w.fail[1] = true;
      w.type('Head', '11');
      await settle();
      check('an edit that could not be sent comes back off the page, and says so',
        w.page() === '100/180/450' && w.state() === '{}' && w.held() === '{}' && w.alerts.length === 1 && w.picker === '{}',
        w.all());
      w.type('Arms', '22');
      await settle();
      check('and the next edit is sent, without the one that failed',
        w.held() === '{"Arms":22}' && w.state() === w.held() && w.page() === '100/22/450' && w.alerts.length === 1, w.all());

      w = world({ Head: 60 });
      w.fail[1] = true;
      w.type('Head', '11');
      await settle();
      check('a failed edit to a damaged location goes back to the damage it had',
        w.page() === '60/180/450' && w.state() === '{"Head":60}' && w.held() === '{"Head":60}', w.all());

      w = world({ Head: 60 });
      w.fail[1] = true;
      w.type('Head', '');
      await settle();
      check('and a failed blanking does too', w.page() === '60/180/450' && w.state() === '{"Head":60}', w.all());

      // The first fails while a second is waiting behind it.
      w = world();
      w.hold[1] = true; w.fail[1] = true;
      w.type('Head', '11'); w.type('Arms', '22');
      await settle(); w.release(); await settle();
      check('an edit waiting behind one that fails is sent without it',
        w.held() === '{"Arms":22}' && w.state() === w.held() && w.page() === '100/22/450' && w.alerts.length === 1, w.all());

      w = world();
      w.hold[1] = true; w.fail[1] = true;
      w.type('Head', '11'); w.type('Head', '12');
      await settle(); w.release(); await settle();
      check('a location typed into again is not taken back when the older request fails',
        w.held() === '{"Head":12}' && w.state() === w.held() && w.page() === '12/180/450', w.all());

      // TWO BROWSERS (reproduced on a local server, 2026-10-12: two requests
      // built from one read both answered 200 and the server kept the second
      // alone). The request is one location and the number it replaces now.
      w = world({ Head: 60 });
      w.type('Head', '50'); w.type('Arms', '22');
      await settle();
      check('an edit is sent as its one location, with the number it replaces',
        JSON.stringify(w.sent) === JSON.stringify([
          { location: 'Head', mdc: { from: 60, to: 50, absent: false } },
          { location: 'Arms', mdc: { from: null, to: 22, absent: true } }]), w.all());

      w = world();
      w.hold[1] = true;
      w.type('Head', '11'); w.type('Head', '12');
      await settle(); w.release(); await settle();
      check('a second number for one location replaces the first, not what the page was first drawn with',
        w.sent[1]?.mdc?.from === 11 && w.sent[1]?.mdc?.absent === false && w.alerts.length === 0, w.all());

      w = world({ Body: 400 });
      w.elsewhere('Arms', 150);
      w.type('Head', '11');
      await settle();
      check('a location changed elsewhere is kept when another is typed into here',
        w.held() === '{"Body":400,"Arms":150,"Head":11}' && w.alerts.length === 0, w.all());

      w = world({ Head: 60 });
      w.elsewhere('Head', 90);
      w.type('Head', '5');
      await settle();
      check('the same location changed elsewhere first is not replaced',
        w.held() === '{"Head":90}', w.all());
      check('and the page is read again, so it shows what is stored',
        w.reads === 1 && w.state() === '{"Head":90}' && w.page() === '90/180/450' && w.picker === w.held(), w.all());
      check('and the player is told once, with their number and the stored one',
        w.alerts.length === 1 && /Head/.test(w.alerts[0]) && /\b90\b/.test(w.alerts[0]) && /\b5\b/.test(w.alerts[0])
          && !/^Failed/.test(w.alerts[0]), w.all());
      w.type('Head', '5');
      await settle();
      check('typed again over what is stored now, it lands',
        w.held() === '{"Head":5}' && w.state() === w.held() && w.alerts.length === 1, w.all());

      w = world({ Head: 60 });
      w.elsewhere('Head', undefined);
      w.type('Head', '50');
      await settle();
      check('a location repaired elsewhere is not damaged again from a stale page, and the message says undamaged',
        w.held() === '{}' && w.page() === '100/180/450' && /undamaged/.test(w.alerts[0] || ''), w.all());

      w = world();
      w.elsewhere('Head', 11);
      w.type('Head', '11');
      await settle();
      check('the same number typed on both sides is not a clash',
        w.held() === '{"Head":11}' && w.alerts.length === 0 && w.reads === 0, w.all());

      // A re-read while an edit is on its way (adding or removing another
      // vessel does one) used to redraw from before the edit was stored.
      w = world();
      w.hold[1] = true;
      w.type('Head', '11');
      const reread = w.fns.refreshVessels();
      await settle();
      check('a re-read waits for a vessel edit that is on its way', w.reads === 0, w.all());
      w.release();
      await reread; await settle();
      check('and then shows it', w.reads === 1 && w.state() === '{"Head":11}' && w.page() === '11/180/450', w.all());

      w = world();
      w.holdRead = true;
      const slow = w.fns.refreshVessels();
      await settle();
      w.type('Head', '11');
      await settle();
      w.releaseRead();
      await slow; await settle();
      check('a read that an edit was typed during is taken again, not drawn',
        w.reads === 2 && w.held() === '{"Head":11}' && w.state() === w.held() && w.page() === '11/180/450', w.all());
    }
  }

  // ---------- The weapon cards are drawn from the inventory, and follow it ----------
  // WRITTEN FROM A LIVE BUG (reproduced on a local server, 2026-10-11). Both
  // modes are in the page at once and switching is a class flip, so the weapon
  // cards sit behind the Gear tab the whole time it is being edited - and only
  // Draw repainted them. A weapon added, ticked equipped, given a quantity or
  // removed on the sheet lens left the cards as the last full render drew
  // them: press Play and an equipped revolver had no card, and a removed one
  // still offered Strike.
  //
  // RUN, not matched: every inventory handler on the sheet and the real card
  // markup, over a stand-in server and a stand-in page.
  section('The weapon cards follow the inventory');
  {
    const sheet = readFileSync(appPath('sheet.js'), 'utf8').replace(/\r\n/g, '\n');
    const fn = (head) => {
      const from = sheet.indexOf('\n' + head), to = sheet.indexOf('\n}\n', from);
      return from < 0 || to < 0 ? null : sheet.slice(from, to + 2);
    };
    const src = ['function isWeapon(it) {', 'function weaponCardsHtml(w, strikeBonus) {',
      'function repaintPlayWeapons() {', 'async function drawWeapon(rowId) {',
      'async function refreshInventory() {', 'async function patchItem(rowId, fields) {',
      'function removeItem(rowId) {', 'async function giveToStash(rowId) {', 'async function addItem() {'].map(fn);
    check('the card markup and the inventory handlers can be located', src.every(Boolean),
      'one of them is not where this looks for it');
    const waiting = fn('const removing = ') || '';
    const clone = (v) => JSON.parse(JSON.stringify(v));
    const row = (id, name, equipped, weapon = true) => ({
      id, item_slug: name.toLowerCase(), item_name: name, qty: 1, equipped,
      item_category: weapon ? 'weapon' : 'gear', item_damage: weapon ? '1D8' : null,
    });

    const world = () => {
      const server = { items: [row(1, 'Sword', 1), row(2, 'Dagger', 0), row(3, 'Rope', 0, false)], nextId: 100 };
      const C = { items: clone(server.items), canWrite: true, playStrike: 0, data: { campaign_id: 4 }, catalog: [{ slug: 'bow', name: 'Bow' }] };
      const field = (value) => ({ value, checked: false });
      const page = {
        'inv-rows': { innerHTML: '' }, 'play-weapons': { innerHTML: '' },
        'add-slug': field(''), 'add-name': field(''), 'add-qty': field('1'), 'add-notes': field(''), 'add-log': field(''),
      };
      const w = { server, C, page, alerts: [] };
      const api = async (path, req) => {
        if (!req) return clone({ items: server.items });
        const body = req.body ? JSON.parse(req.body) : {};
        const [, rowId, stash] = /\/items(?:\/(\d+))?(\/stash)?$/.exec(path);
        const at = server.items.find((x) => x.id === +rowId);
        if (!rowId) server.items.push({ ...row(++server.nextId, 'Bow', 0), qty: body.qty });
        else if (stash || req.method === 'DELETE') server.items = server.items.filter((x) => x !== at);
        else {
          if ('equipped' in body) at.equipped = body.equipped ? 1 : 0;
          if ('qty' in body) at.qty = +body.qty;
        }
        return { ok: true };
      };
      // The Undo toast, cut down to its three callbacks.
      const undoable = (op) => { w.op = op; op.hide(); };
      w.fns = new Function('C', 'id', 'api', '$', 'undoable', 'inventoryRowsHtml', 'jsonReq', 'escJs', 'escHtml',
        'leadingDice', 'payloadCapacity', 'currentAmmo', 'codexLink', 'strikeChipsHtml', 'playSecOpen',
        'alert', 'flash', 'prompt', 'load', 'dropDrafts',
        waiting + src.join('\n')
          + '; return { repaintPlayWeapons, drawWeapon, refreshInventory, patchItem, removeItem, giveToStash, addItem };')(
        C, 3, api, (elId) => page[elId] || null, undoable, () => C.items.map((x) => x.item_name).join(','),
        (method, body) => ({ method, body: JSON.stringify(body) }), String, String,
        (dice) => dice, () => null, () => null, () => '', () => '', () => true,
        (msg) => { w.alerts.push(msg); }, () => {}, () => null, async () => {}, () => {});
      // What render() leaves behind: the cards as the rows stood then.
      w.fns.repaintPlayWeapons();
      // "drawn | carried", the way the play strip shows them.
      w.cards = () => {
        const html = page['play-weapons'].innerHTML;
        const drawn = [...html.matchAll(/<div class="pw-head"><b>([^<]*)<\/b>(?: <span class="muted small">(×\d+)<\/span>)?/g)]
          .map((m) => m[1] + (m[2] || ''));
        const carried = [...html.matchAll(/<span class="pw-carry">([^<]*)</g)].map((m) => m[1].trim());
        return `${drawn.join(',') || '-'} | ${carried.join(',') || '-'}`;
      };
      w.held = () => server.items.map((x) => `${x.item_name}${x.qty > 1 ? '×' + x.qty : ''}${x.equipped ? '*' : ''}`).join(',');
      return w;
    };

    if (src.every(Boolean)) {
      const w = world();
      const both = () => JSON.stringify({ cards: w.cards(), server: w.held(), alerts: w.alerts });
      check('the cards start as the rows stand: the equipped weapon drawn, the other carried, the rope neither',
        w.cards() === 'Sword | Dagger', both());

      await w.fns.patchItem(2, { equipped: true });
      check('a weapon ticked equipped on the Gear tab gets its card',
        w.cards() === 'Sword,Dagger | -' && w.held() === 'Sword*,Dagger*,Rope', both());
      await w.fns.patchItem(1, { equipped: false });
      check('and one unticked goes back to carried',
        w.cards() === 'Dagger | Sword' && w.held() === 'Sword,Dagger*,Rope', both());
      await w.fns.patchItem(2, { qty: '3' });
      check('a quantity typed there shows on the card',
        w.cards() === 'Dagger×3 | Sword' && w.held() === 'Sword,Dagger×3*,Rope', both());

      w.page['add-slug'].value = 'bow';
      await w.fns.addItem();
      check('a weapon added from the catalog is offered to draw',
        w.cards() === 'Dagger×3 | Sword,Bow' && w.held() === 'Sword,Dagger×3*,Rope,Bow', both());
      await w.fns.drawWeapon(101);
      check('and Draw still gives it a card', w.cards() === 'Dagger×3,Bow | Sword', both());

      w.fns.removeItem(2);
      check('a weapon removed loses its card at once, while its Undo is still up',
        w.cards() === 'Bow | Sword' && w.held() === 'Sword,Dagger×3*,Rope,Bow*', both());
      w.op.restore();
      check('Undo brings the card back', w.cards() === 'Dagger×3,Bow | Sword', both());
      w.fns.removeItem(2);
      await w.op.commit(false);
      check('and left alone it is deleted, card and all',
        w.cards() === 'Bow | Sword' && w.held() === 'Sword,Rope,Bow*', both());

      await w.fns.giveToStash(1);
      check('a weapon given to the party stash is no longer on offer',
        w.cards() === 'Bow | -' && w.held() === 'Rope,Bow*', both());

      // No holder at all (a sheet drawn before the strip exists): the
      // inventory must still repaint, and nothing may throw into the alert.
      w.page['play-weapons'] = null;
      await w.fns.patchItem(101, { qty: '2' });
      check('with no card holder on the page the inventory still repaints, quietly',
        w.page['inv-rows'].innerHTML === 'Rope,Bow' && w.held() === 'Rope,Bow×2*' && !w.alerts.length,
        JSON.stringify({ rows: w.page['inv-rows'].innerHTML, server: w.held(), alerts: w.alerts }));
    }
  }

  // ---------- An item that was not added leaves no note saying it was ----------
  // Add with "log it" ticked writes the journal entry FIRST, because the item
  // row carries the entry's id. The item POST was then free to fail - a
  // quantity the server refuses, a catalog row gone - and the entry stayed:
  // "Acquired Bow" on the Notes tab, for a bow nobody holds.
  //
  // A refusal takes the entry back. A SILENCE does not, for the reason the pool
  // presses give: a write that got no answer may have landed, and deleting the
  // note of an item that did arrive is the same mistake the other way round.
  //
  // RUN, not matched: the sheet's own addItem over a stand-in server.
  section('An item that was not added leaves no note saying it was');
  {
    const sheet = readFileSync(appPath('sheet.js'), 'utf8').replace(/\r\n/g, '\n');
    const from = sheet.indexOf('\nasync function addItem() {'), to = sheet.indexOf('\n}\n', from);
    const src = from < 0 || to < 0 ? null : sheet.slice(from, to + 2);
    check('addItem can be located', !!src, 'it is not where this looks for it');

    const world = () => {
      const server = { items: [], journal: [], nextId: 40 };
      const field = (value, checked = false) => ({ value, checked });
      const page = { 'add-slug': field('bow'), 'add-name': field(''), 'add-qty': field('2'),
        'add-notes': field(''), 'add-log': field('', true) };
      const w = { server, page, alerts: [], calls: [], fail: {}, reloads: 0 };
      const api = async (path, req) => {
        const method = req?.method || 'GET';
        w.calls.push(`${method} ${path}`);
        const body = req?.body ? JSON.parse(req.body) : {};
        const entry = /^journal\/(\d+)$/.exec(path);
        if (path === 'journal') {
          if (w.fail.log) throw w.fail.log;
          const made = { id: ++server.nextId, title: body.title };
          server.journal.push(made);
          return { entry: made };
        }
        if (entry && method === 'DELETE') {
          if (w.fail.unlog) throw w.fail.unlog;
          server.journal = server.journal.filter((e) => e.id !== +entry[1]);
          return { ok: true };
        }
        if (/\/items$/.test(path) && method === 'POST') {
          // The request arrives and the answer is lost on the way back.
          if (w.fail.answer) { server.items.push(body); throw w.fail.answer; }
          if (w.fail.item) throw w.fail.item;
          server.items.push(body);
          return { ok: true };
        }
        throw new Error('the stand-in server has no ' + method + ' ' + path);
      };
      w.fns = new Function('C', 'id', 'api', '$', 'jsonReq', 'alert', 'load', 'dropDrafts', 'refreshInventory',
        src + '; return { addItem };')(
        { catalog: [{ slug: 'bow', name: 'Bow' }] }, 3, api, (elId) => page[elId] || null,
        (method, body) => ({ method, body: JSON.stringify(body) }), (msg) => { w.alerts.push(msg); },
        async () => { w.reloads++; if (w.fail.reload) throw w.fail.reload; }, () => {}, async () => {});
      w.all = () => JSON.stringify({ items: server.items.length, journal: server.journal.map((e) => e.title),
        alerts: w.alerts, calls: w.calls });
      return w;
    };
    const refused = () => Object.assign(new Error('qty is too large'), { status: 400 });
    const silence = () => new Error('Failed to fetch');

    if (src) {
      let w = world();
      await w.fns.addItem();
      check('an item added with "log it" has its entry, and points at it',
        w.server.items.length === 1 && w.server.journal.length === 1
          && w.server.items[0].journal_entry_id === w.server.journal[0].id && !w.alerts.length, w.all());

      w = world(); w.fail.item = refused();
      await w.fns.addItem();
      check('an item the server refused leaves no journal entry behind',
        w.server.items.length === 0 && w.server.journal.length === 0, w.all());
      check('and the refusal is still reported, as it was',
        w.alerts.length === 1 && w.alerts[0].includes('qty is too large'), w.all());

      w = world(); w.fail.item = refused(); w.fail.unlog = silence();
      await w.fns.addItem();
      check('an entry that could not be taken back is named, so it can be deleted by hand',
        w.server.journal.length === 1 && w.alerts.length === 1 && w.alerts[0].includes('Inventory: Bow'), w.all());

      w = world(); w.fail.answer = silence();
      await w.fns.addItem();
      check('an add that got no answer keeps its entry: the item may have arrived',
        w.server.items.length === 1 && w.server.journal.length === 1 && !w.calls.some((c) => c.startsWith('DELETE')), w.all());
      check('and says the entry was written, since nothing else on the page will',
        w.alerts.length === 1 && w.alerts[0].includes('Inventory: Bow'), w.all());

      w = world(); w.fail.log = refused();
      await w.fns.addItem();
      check('an entry that was never written is not taken back, and no item is sent after it',
        w.calls.join(', ') === 'POST journal' && w.alerts.length === 1, w.all());

      w = world(); w.fail.reload = silence();
      await w.fns.addItem();
      check('a reload that fails after the item landed takes nothing back',
        w.server.items.length === 1 && w.server.journal.length === 1 && w.reloads === 1
          && !w.calls.some((c) => c.startsWith('DELETE')), w.all());
    }
  }

  // ---------- Pool presses go out one at a time ----------
  // A +/- press is guarded: it says what the pool held and what it should hold,
  // and the server refuses it when the first number is wrong. Each press is
  // drawn at once and was SENT at once too, so two quick presses were two
  // requests in flight, the second built on a number the server did not hold
  // until the first arrived. Nothing orders two requests on a phone's
  // connection. The second arriving first was refused as "changed elsewhere",
  // retried from the old number and collided with the first: one press was
  // lost, an alert said Failed, and the screen and the server disagreed.
  //
  // The drawing is still immediate. Only the sending waits its turn.
  //
  // RUN, not matched: the sheet's own adjustPool and applyChanges and the real
  // derive.js, over a stand-in server that holds every request until this
  // section answers it, in whatever order it likes, by the events route's rule.
  section('Pool presses go out one at a time');
  {
    const sheet = readFileSync(appPath('sheet.js'), 'utf8').replace(/\r\n/g, '\n');
    const fn = (head) => {
      const from = sheet.indexOf('\n' + head), to = sheet.indexOf('\n}\n', from);
      return from < 0 || to < 0 ? null : sheet.slice(from, to + 2);
    };
    const press = fn('async function adjustPool('), apply = fn('function applyChanges(changes, side) {');
    // New with the fix, so optional: against the old file the checks below
    // must FAIL, not stop at "cannot be located".
    const turn = (/\nlet poolSends = [^\n]*\n/.exec(sheet) || [''])[0] + (fn('async function sendPoolPress(') || '');
    check('adjustPool and applyChanges can be located', !!press && !!apply, 'one of them is not where this looks for it');
    const win = {};
    new Function('globalThis', readFileSync(join(appDir, 'js', 'derive.js'), 'utf8')).call(win, win);
    const settle = async () => { for (let i = 0; i < 25; i++) await null; };

    const world = (hp = 10) => {
      const server = { hp_current: hp };
      const C = { data: { hp_current: hp }, secondForm: null };
      const w = { server, C, wire: [], sent: 0, alerts: [], flashes: [], queued: [], fail: null };
      const api = (path, req) => new Promise((resolve, reject) => {
        w.sent++;
        w.wire.push({ body: JSON.parse(req.body), resolve, reject });
      });
      // functions/api/character-creator/characters/[id]/events.js: a guarded
      // field whose `from` is not what is stored is a 409 carrying what is.
      w.answer = (req) => {
        if (w.fail) return req.reject(w.fail);
        const fields = req.body.changes.character || {};
        const stale = Object.entries(fields).filter(([f, v]) => req.body.guard && server[f] !== v.from);
        if (stale.length) {
          return req.reject(Object.assign(new Error('changed elsewhere'), { status: 409,
            detail: { fields: Object.fromEntries(stale.map(([f, v]) => [f, { mine: v.to, theirs: server[f], base: v.from }])) } }));
        }
        for (const [f, v] of Object.entries(fields)) server[f] = v.to;
        return req.resolve({ ok: true });
      };
      // Every request in flight, oldest first, until none is left.
      w.drain = async () => {
        for (let n = 0; n < 20 && (await settle(), w.wire.length); n++) w.answer(w.wire.shift());
        await settle();
      };
      w.fns = new Function('C', 'id', 'derive', 'api', 'jsonReq', 'poolData', 'paintPool', 'syncPowerBtns',
        'flash', 'alert', 'queueChange', 'renderQueueState', 'formExtra',
        turn + apply + press + '; return { adjustPool };')(
        C, 3, win.derive, api, (method, body) => ({ method, body: JSON.stringify(body) }), () => C.data,
        () => {}, () => {}, (msg) => { w.flashes.push(msg); }, (msg) => { w.alerts.push(msg); },
        async (kind, note) => { w.queued.push(note); return true; }, () => {}, () => undefined);
      w.all = () => JSON.stringify({ server: server.hp_current, screen: C.data.hp_current, sent: w.sent,
        inFlight: w.wire.length, alerts: w.alerts, flashes: w.flashes, queued: w.queued });
      return w;
    };

    if (press && apply) {
      let w = world();
      w.fns.adjustPool('hp', 1); w.fns.adjustPool('hp', 1);
      await settle();
      check('two quick presses are both on the screen at once', w.C.data.hp_current === 12, w.all());
      check('and the second is not sent until the first has its answer', w.sent === 1 && w.wire.length === 1, w.all());
      // Whatever is in flight, the newest reaches the server first.
      if (w.wire.length > 1) w.answer(w.wire.pop());
      await w.drain();
      check('two presses of +1 leave the server and the screen two higher',
        w.server.hp_current === 12 && w.C.data.hp_current === 12, w.all());
      check('with nothing reported as changed elsewhere, and nothing as failed',
        !w.alerts.length && !w.flashes.length && w.sent === 2, w.all());

      // The G.M. really did move it: both presses land on the G.M.'s number.
      w = world();
      w.server.hp_current = 20;
      w.fns.adjustPool('hp', 1); w.fns.adjustPool('hp', 1);
      await w.drain();
      check('two presses on a pool somebody else moved both land on their number',
        w.server.hp_current === 22 && w.C.data.hp_current === 22 && !w.alerts.length && w.flashes.length >= 1, w.all());

      w = world(); w.fail = new Error('Failed to fetch');
      w.fns.adjustPool('hp', -1); w.fns.adjustPool('hp', -1);
      await w.drain();
      check('presses the network ate wait in the queue in the order they were made, and stay on screen',
        w.queued.join(', ') === 'HP -1, HP -1' && w.C.data.hp_current === 8 && !w.alerts.length, w.all());

      w = world(); w.fail = Object.assign(new Error('no such character'), { status: 404 });
      w.fns.adjustPool('hp', 1);
      await w.drain();
      check('a press the server refused comes off the screen and says so',
        w.C.data.hp_current === 10 && w.alerts.length === 1, w.all());
      w.fail = null;
      const done = w.fns.adjustPool('hp', 1);
      await w.drain();
      check('and the press after a refused one is still sent',
        w.server.hp_current === 11 && w.C.data.hp_current === 11 && w.alerts.length === 1, w.all());
      check('a press answers its caller only when its request has been answered',
        await Promise.race([done.then(() => true), settle().then(() => false)]), 'the promise adjustPool returned is still pending');
    }
  }

  // ---------- A power spend is guarded on the number it was made from ----------
  // A spell's ⚡ posted its from/to without `guard`, so the events route wrote
  // `to` blindly: a play-mode sheet showing 30 P.P.E. that the G.M. had set to
  // 20 cast a 1-point spell and stored 29. Its sheet-view branch PATCHed the
  // absolute number with no expect_updated_at, the same loss by another road.
  // Reproduced on a local server 2026-10-19 before the fix: both stored 29.
  //
  // RUN, not matched: the sheet's own usePower and what it calls, over a
  // stand-in for the events route's guard and the PATCH's version check.
  section('A power spend is guarded on the number it was made from');
  {
    const sheet = readFileSync(appPath('sheet.js'), 'utf8').replace(/\r\n/g, '\n');
    const fn = (head) => {
      const from = sheet.indexOf('\n' + head), to = sheet.indexOf('\n}\n', from);
      return from < 0 || to < 0 ? null : sheet.slice(from, to + 2);
    };
    const use = fn('async function usePower(index) {'), pool = fn('function powerPool(p) {');
    // New with the fix, so optional: against the old file the checks below
    // must FAIL, not stop at "cannot be located".
    const added = (/\nlet poolSends = [^\n]*\n/.exec(sheet) || [''])[0]
      + (fn('async function sendPowerUse(') || '') + (fn('async function spendInSheetView(') || '');
    check('usePower and powerPool can be located', !!use && !!pool, 'one of them is not where this looks for it');

    const world = ({ play, screen = 30, stored = screen, cost = 1, fail = null }) => {
      const server = { ppe_current: stored, updated_at: stored === screen ? 'v1' : 'v2' };
      const C = { playMode: play, data: { ppe_current: screen, updated_at: 'v1',
        powers: [{ type: 'spell', name: 'Bolt', cost }] } };
      const w = { server, C, bodies: [], alerts: [], flashes: [], logged: 0, queued: 0 };
      const api = async (path, req) => {
        await null;
        if (fail) throw fail;
        if (!req) return { character: { ...server } };
        const body = JSON.parse(req.body);
        w.bodies.push(body);
        if (req.method === 'PATCH') {
          // functions/api/character-creator/characters/[id].js: a stale version is refused.
          if (body.expect_updated_at && body.expect_updated_at !== server.updated_at) {
            throw Object.assign(new Error('changed elsewhere'), { status: 409, detail: { conflict: true } });
          }
          server.ppe_current = body.ppe_current;
          server.updated_at = 'v' + (Number(server.updated_at.slice(1)) + 1);
          return { ok: true, updated_at: server.updated_at };
        }
        // .../characters/[id]/events.js: a guarded field whose `from` is not stored.
        const f = body.changes.character.ppe_current;
        if (body.guard && server.ppe_current !== f.from) {
          throw Object.assign(new Error('changed elsewhere'), { status: 409, detail: { conflict: true,
            fields: { ppe_current: { mine: f.to, theirs: server.ppe_current, base: f.from } } } });
        }
        server.ppe_current = f.to;
        server.updated_at = 'v' + (Number(server.updated_at.slice(1)) + 1);
        return { ok: true };
      };
      const jsonReq = (method, body) => ({ method, body: JSON.stringify(body) });
      w.fns = new Function('C', 'id', 'api', 'jsonReq', 'postEvent', 'paintPool', 'syncPowerBtns', 'recordRoll',
        'flash', 'alert', 'queueChange', 'renderQueueState', 'load',
        added + pool + use + '; return { usePower };')(
        C, 3, api, jsonReq, (kind, note, changes) => api('characters/3/events', jsonReq('POST', { kind, note, changes })),
        () => {}, () => {}, () => { w.logged++; }, (m) => { w.flashes.push(m); }, (m) => { w.alerts.push(m); },
        async () => { w.queued++; return true; }, () => {},
        async () => { C.data = { ...C.data, ...(await api('characters/3')).character }; });
      w.all = () => JSON.stringify({ server: server.ppe_current, screen: C.data.ppe_current, sent: w.bodies,
        alerts: w.alerts, flashes: w.flashes, logged: w.logged, queued: w.queued });
      return w;
    };

    if (use && pool) {
      let w = world({ play: true });
      await w.fns.usePower(0);
      check('in play mode a spend nobody else touched is sent guarded and lands',
        w.server.ppe_current === 29 && w.C.data.ppe_current === 29 && w.bodies.length === 1
          && w.bodies[0].guard === true && w.logged === 1 && !w.alerts.length && !w.flashes.length, w.all());

      w = world({ play: true, stored: 20 });
      await w.fns.usePower(0);
      check('in play mode a spend on a pool set elsewhere comes out of what is stored, not what was shown',
        w.server.ppe_current === 19 && w.C.data.ppe_current === 19, w.all());
      check('and says so, and is logged once', w.flashes.length === 1 && !w.alerts.length && w.logged === 1, w.all());

      w = world({ play: true, stored: 3, cost: 5, screen: 30 });
      await w.fns.usePower(0);
      check('in play mode a spend the stored pool can no longer pay is stopped, and the screen shows what is stored',
        w.server.ppe_current === 3 && w.C.data.ppe_current === 3 && w.alerts.length === 1 && w.logged === 0, w.all());

      w = world({ play: true, fail: new Error('Failed to fetch') });
      await w.fns.usePower(0);
      check('in play mode a spend the network ate still waits in the queue, and stays on screen',
        w.queued === 1 && w.C.data.ppe_current === 29 && !w.alerts.length, w.all());

      w = world({ play: false });
      await w.fns.usePower(0);
      check('in sheet view a spend carries the version it was read at, and lands',
        w.server.ppe_current === 29 && w.bodies.length === 1 && w.bodies[0].expect_updated_at === 'v1'
          && !w.alerts.length, w.all());

      w = world({ play: false, stored: 20 });
      await w.fns.usePower(0);
      check('in sheet view a spend on a pool set elsewhere comes out of what is stored, not what was shown',
        w.server.ppe_current === 19 && w.C.data.ppe_current === 19 && !w.alerts.length, w.all());

      w = world({ play: false, stored: 0 });
      await w.fns.usePower(0);
      check('in sheet view a spend the stored pool can no longer pay is stopped',
        w.server.ppe_current === 0 && w.alerts.length === 1, w.all());
    }
  }

  // ---------- An overflow that was refused is still on offer ----------
  // What armour could not absorb is offered to the body: "Apply 8 to body".
  // Pressing it ran the body's damage and then wrote "took the 8 that got past
  // Plate" into the roll log and withdrew the offer - whatever the damage did.
  // The damage rolls itself back when the server refuses it, so the log said a
  // hit landed that had just been taken off the screen, and the button to try
  // again was gone.
  //
  // RUN, not matched: the sheet's own applyOverflow, bodyDamage and
  // applyChanges and the real derive.js, over a stand-in events route.
  section('An overflow that was refused is still on offer');
  {
    const sheet = readFileSync(appPath('sheet.js'), 'utf8').replace(/\r\n/g, '\n');
    const fn = (head) => {
      const from = sheet.indexOf('\n' + head), to = sheet.indexOf('\n}\n', from);
      return from < 0 || to < 0 ? null : sheet.slice(from, to + 2);
    };
    const src = ['async function bodyDamage(amt) {', 'async function applyOverflow() {',
      'function applyChanges(changes, side) {'].map(fn);
    check('applyOverflow, bodyDamage and applyChanges can be located', src.every(Boolean),
      'one of them is not where this looks for it');
    const win = {};
    new Function('globalThis', readFileSync(join(appDir, 'js', 'derive.js'), 'utf8')).call(win, win);

    const world = () => {
      const C = { data: { sdc_current: 5, hp_current: 20 }, secondForm: null, lastRoll: null,
        overflow: { amount: 8, label: 'Plate' } };
      const bar = { innerHTML: 'Apply 8 to body' };
      const w = { C, bar, log: [], posts: 0, queued: 0, alerts: [], fail: null, during: null };
      // What the real one does that matters here: any new result retires the offer.
      const recordRoll = (kind, name, entry) => {
        C.overflow = null; C.lastRoll = { kind, name, ...entry };
        w.log.push(`${name}: ${entry.note}`); bar.innerHTML = name;
      };
      w.recordRoll = recordRoll;
      w.fns = new Function('C', 'derive', '$', 'poolData', 'paintPool', 'syncPowerBtns', 'postEvent', 'queueChange',
        'renderQueueState', 'formExtra', 'recordRoll', 'rollBarHtml', 'alert',
        src.join('\n') + '; return { applyOverflow };')(
        C, win.derive, (elId) => (elId === 'roll-line' ? bar : null), () => C.data, () => {}, () => {},
        async () => { w.posts++; await w.during?.(); if (w.fail) throw w.fail; }, async () => { w.queued++; return true; },
        () => {}, () => undefined, recordRoll,
        () => (C.overflow ? `Apply ${C.overflow.amount} to body` : (C.lastRoll?.name ?? '')), (msg) => { w.alerts.push(msg); });
      w.all = () => JSON.stringify({ pools: [C.data.sdc_current, C.data.hp_current], offer: C.overflow, log: w.log,
        bar: bar.innerHTML, posts: w.posts, queued: w.queued, alerts: w.alerts });
      return w;
    };
    const pools = (w) => `${w.C.data.sdc_current}/${w.C.data.hp_current}`;

    if (src.every(Boolean)) {
      let w = world();
      await w.fns.applyOverflow();
      check('an overflow applied comes off the body, is logged, and is no longer offered',
        pools(w) === '0/17' && w.log.join() === 'Body: took the 8 that got past Plate' && w.C.overflow === null, w.all());

      w = world(); w.fail = Object.assign(new Error('no such character'), { status: 404 });
      await w.fns.applyOverflow();
      check('an overflow the server refused comes back off the screen', pools(w) === '5/20' && w.alerts.length === 1, w.all());
      check('is not written to the roll log as taken', w.log.length === 0, w.all());
      check('and is still on offer', w.C.overflow?.amount === 8 && w.C.overflow?.label === 'Plate'
        && w.bar.innerHTML === 'Apply 8 to body', w.all());

      w = world(); w.fail = new Error('Failed to fetch');
      await w.fns.applyOverflow();
      check('one the network ate stands, as any hit does: queued, logged, and not offered twice',
        pools(w) === '0/17' && w.queued === 1 && w.log.length === 1 && w.C.overflow === null, w.all());

      w = world(); w.fail = Object.assign(new Error('no such character'), { status: 404 });
      w.during = () => { w.recordRoll('skill', 'Climb', { note: '41 vs 60%' }); };
      await w.fns.applyOverflow();
      check('a refused overflow is not offered again once the table has rolled something newer',
        w.C.overflow === null && w.bar.innerHTML === 'Climb' && w.log.join() === 'Climb: 41 vs 60%', w.all());

      w = world();
      await Promise.all([w.fns.applyOverflow(), w.fns.applyOverflow()]);
      check('a second tap while the first is in flight applies nothing more', w.posts === 1 && pools(w) === '0/17', w.all());
    }
  }

  // ---------- A value is escaped for the place it is written into ----------
  // Four slips of one rule (shared/js/ui.js): escHtml for markup and for an
  // attribute, escJs for a string inside an inline handler. Each of these had
  // the other one, or neither.
  //
  //   * the enchantment's remove button put escHtml(slug) inside a handler's
  //     string, where an apostrophe ends the string and the button is dead;
  //   * the roll button put escJs(name) in its aria-label, so a screen reader
  //     read a backslash in front of every apostrophe;
  //   * two panel headings opened as <h2> and closed as </h3>;
  //   * and the language-family rules, which arrive by a module tag, were read
  //     as a bare global by render(), so a sheet drawn before that tag ran (or
  //     without it, on a failed request) was a ReferenceError and a page stuck
  //     on "Loading sheet".
  //
  // RUN where it can be: the markup functions themselves, with the handler and
  // the label read back the way a browser reads an attribute.
  section('A value is escaped for the place it is written into');
  {
    const sheet = readFileSync(appPath('sheet.js'), 'utf8').replace(/\r\n/g, '\n');
    const ui = readFileSync(join(repoRoot, 'shared', 'js', 'ui.js'), 'utf8');
    const whole = (src, sig) => { const b = functionBody(src, sig); return b === null ? null : b + '\n}'; };
    const parts = [whole(ui, 'function escHtml('), whole(ui, 'function escJs('), whole(sheet, 'function rollBtn('),
      whole(sheet, 'function rollTarget('), whole(sheet, 'function enchantBySlug('),
      whole(sheet, 'function enchantEffect('), whole(sheet, 'function enchantHtml(')];
    check('the markup functions these checks run can be located', parts.every((x) => x !== null),
      'a signature moved - nothing below would run');
    // An attribute's value as the browser hands it on: character references decoded.
    const decode = (s) => s.replace(/&(amp|lt|gt|quot|#39);/g, (_, n) => ({ amp: '&', lt: '<', gt: '>', quot: '"', '#39': "'" }[n]));
    const attr = (html, name) => { const m = new RegExp(`${name}="([^"]*)"`).exec(html); return m ? decode(m[1]) : null; };

    if (parts.every((x) => x !== null)) {
      const C = { canWrite: true, enchantCatalog: [] };
      const fns = new Function('C', parts.join('\n') + '\nreturn { rollBtn, enchantHtml };')(C);
      for (const slug of ['flaming', "smith's-mark", 'a\\b', 'x"y', '<b>&amp;', "');alert(1);('"]) {
        C.enchantCatalog = [{ slug, name: 'Test', applies_to: 'weapon' }];
        const handler = attr(fns.enchantHtml({ id: 7, enchantments: [slug] }), 'onclick');
        let got = null, why = '';
        try { new Function('removeEnchantment', 'alert', handler)((row, sl) => { got = [row, sl]; }, () => { got = 'ran script'; }); }
        catch (e) { why = e.message; }
        check('the remove button hands its handler the enchantment it was drawn for: ' + slug,
          Array.isArray(got) && got[0] === 7 && got[1] === slug, `${handler} -> ${JSON.stringify(got)} ${why}`);
      }

      for (const name of ['Climbing', "Driver's Ed", 'Lore: "Demons" & Monsters', 'a\\b']) {
        const html = fns.rollBtn({ name, pct: 50 });
        check('the roll button is labelled with the name as written: ' + name,
          attr(html, 'aria-label') === 'Roll ' + name, attr(html, 'aria-label'));
        let rolled = null;
        try { new Function('rollSkill', attr(html, 'onclick'))((n) => { rolled = n; }); } catch { /* reported below */ }
        check('and still rolls that skill', rolled === name, `${attr(html, 'onclick')} -> ${rolled}`);
      }
    }

    // Headings, in file order, with the comment lines taken out: each one opened
    // is closed at its own level before the next opens.
    const code = sheet.split('\n').map((line, i) => [line, i + 1]).filter(([line]) => !/^\s*\/\//.test(line));
    const mismatched = [];
    let open = null;
    for (const [line, at] of code) {
      for (const [, close, level] of line.matchAll(/<(\/?)h([1-6])\b/g)) {
        if (!close) { if (open) mismatched.push(`h${open.level} at ${open.at} never closed`); open = { level, at }; }
        else if (!open) mismatched.push(`</h${level}> at ${at} closes nothing`);
        else { if (open.level !== level) mismatched.push(`<h${open.level}> at ${open.at} closed as </h${level}> at ${at}`); open = null; }
      }
    }
    check('the sheet draws headings at all, or the next check reads nothing',
      code.some(([line]) => /<h[1-6]\b/.test(line)), 'no heading tag found in sheet.js');
    check('every heading the sheet opens is closed at the same level', mismatched.length === 0 && open === null,
      mismatched.join('; '));

    // The language rules: read through globalThis, and survivable when absent.
    const bare = code.filter(([line]) => /(?<![.\w])langSkills\b/.test(line)).map(([, at]) => at);
    check('no line of the sheet reads the language rules as a bare global', bare.length === 0,
      'sheet.js lines ' + bare.join(', '));
    check('and the sheet does read them, or that check passes on nothing',
      code.some(([line]) => /globalThis\.langSkills\b/.test(line)), 'no globalThis.langSkills in sheet.js');
    const from = sheet.indexOf('\n  const clusterLanguages = '), to = sheet.indexOf('\n  };\n', from);
    const cluster = from < 0 || to < 0 ? null : sheet.slice(from, to + 6);
    check('the language clustering can be located', !!cluster, 'render() no longer declares clusterLanguages where this looks');
    if (cluster) {
      const run = () => new Function(cluster + '\nreturn clusterLanguages;')()(
        ['Climbing', 'Literacy: Elven', 'Swimming', 'Language: Orc'].map((name) => ({ name }))).map((s) => s.name).join(', ');
      const { isFamilyName } = await import('../../js/language-skills.js');
      const had = globalThis.langSkills;
      let without = null, withRules = null, why = '';
      try {
        delete globalThis.langSkills;
        try { without = run(); } catch (e) { why = e.message; }
        globalThis.langSkills = { isFamilyName };
        try { withRules = run(); } catch (e) { why = e.message; }
      } finally { globalThis.langSkills = had; }
      check('a sheet drawn before the language rules arrive lists its skills as stored',
        without === 'Climbing, Literacy: Elven, Swimming, Language: Orc', without ?? why);
      check('and with them, gathers the languages where the first one stood',
        withRules === 'Climbing, Language: Orc, Literacy: Elven, Swimming', withRules ?? why);
    }
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
      /if \(group && !groupsOf\(sec, r\)\.includes\(group\)\) return false/.test(js)
        && /return sec\.groups \? sec\.groups\(r\) : \[sec\.meta\(r\)\]/.test(js)
        && /return sortRows\(sec, rows\)/.test(js)
        && /x == null \? 1 : -1/.test(js)
        && /new URLSearchParams\(location\.search\)/.test(js)
        && /history\.replaceState\(null, '', location\.pathname \+ \(qs \?/.test(js),
      'codex.js lost its group filter, its sort, or the query string that makes a filtered view a link');
    // Gear lists one entry per NAME with every book inside it. Run, not read:
    // the fold has no DOM in it so that this can call it. The rows are the
    // shapes production holds - a name three books print in two spellings, a
    // name two books file under different categories, and a slug that sorts
    // after its entry's key, which is the one a sheet link is likeliest to
    // carry.
    {
      const mod = { exports: {} };
      new Function('module', 'window', readFileSync(join(appDir, '..', 'codex', 'name-groups.js'), 'utf8'))(mod, undefined);
      const G = mod.exports;
      const rows = [
        { slug: 'espandon', name: '2-Handed Espandon', system: 'palladium-fantasy', category: 'weapon', cost: 60, source_book: 'Palladium RPG Main Book p.271', description: 'pf' },
        { slug: 'lantern', name: 'Lantern', system: 'rifts', category: 'gear', cost: 5, source_book: 'Rifts Ultimate Edition p.262' },
        { slug: '2-handed-espandon-nb', name: '2-handed Espandon ', system: 'nightbane', category: 'weapon', cost: 460, source_book: 'Nightbane RPG p.205' },
        { slug: 'eggshell-bomb', name: 'Eggshell Bomb', system: 'heroes-unlimited', category: 'gear', cost: 5, source_book: 'Revised Heroes Unlimited p.197' },
        { slug: 'eggshell-bomb-rifts', name: 'Eggshell Bomb', system: 'rifts', category: 'weapon', cost: 35, source_book: 'Rifts World Book 8: Japan p.54' },
      ];
      const groups = G.fold(rows);
      const esp = groups.find((g) => g.slugs.includes('espandon'));
      check('gear is listed once per name, whatever the case, with every book inside',
        groups.length === 3 && esp?.printings.length === 2
          && groups.reduce((n, g) => n + g.printings.length, 0) === rows.length,
        JSON.stringify(groups.map((g) => [g.name, g.slugs])));
      check('and a name two books file under different categories is still one entry',
        groups.find((g) => g.name === 'Eggshell Bomb')?.printings.length === 2);
      check('any printing\'s slug opens its entry, not only the first',
        !!esp && G.resolve(groups, 'espandon') === esp.key
          && G.resolve(groups, '2-Handed-Espandon-NB') === esp.key
          && G.resolve(groups, 'no-such-slug') === null,
        `key ${esp?.key}`);
      const pf = esp && G.narrow(esp, 'palladium-fantasy');
      check('a system filter narrows an entry to that game\'s books and keeps its key',
        pf?.printings.length === 1 && pf.printings[0].slug === 'espandon' && pf.key === esp.key
          && G.narrow(esp, 'rifts') === null && G.narrow(esp, '') === esp,
        JSON.stringify(pf && [pf.key, pf.slugs]));
      check('the page loads the fold before the script that calls it, and asks it for gear',
        /src="name-groups\.js"[\s\S]*src="codex\.js"/.test(html)
          && /fold: \(rows\) => NameGroups\.fold\(rows\)/.test(js)
          && /sec\.fold \? sec\.fold\(res\[id\] \|\| \[\]\)/.test(js),
        'codex.html no longer loads name-groups.js first, or the gear section stopped folding its rows');
      // Vessels fold the same way. The two sections must not share a holdings
      // bucket: a book line's "yours" reads the section it is drawn in.
      check('vessels are listed once per name too, through the same fold',
        (js.match(/fold: \(rows\) => NameGroups\.fold\(rows\)/g) || []).length === 2
          && /countKey: 'vehicle_names'/.test(js)
          && /const VESSEL_LINES = \{ sec: 'vehicles'/.test(js) && /const GEAR_LINES = \{ sec: 'gear'/.test(js)
          && /S\.holdings\?\.holds\?\.\[lines\.sec\]/.test(js),
        'the Vessels tab stopped folding its rows, or its book lines read gear holdings');
      check('and an entry\'s "yours" reads every printing a character could hold',
        /sec\.keys \? sec\.keys\(r\) : \[sec\.key\(r\)\]/.test(js) && /keys: \(r\) => r\.slugs/.test(js),
        'a character holding the second printing of an item would not mark its entry');
    }
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
    // The room view is shared by every game's GM page
    // (shared/js/campaign/present.js), so that file is where SHOW IS NOT
    // REVEAL is held and read. apps/gm-tools/present.js is this game's half:
    // where leaving goes, and the City Creator's maps.
    const gmDir = join(repoRoot, 'apps', 'gm-tools');
    const presentHtml = readFileSync(join(gmDir, 'present.html'), 'utf8');
    const presentJs = readFileSync(join(repoRoot, 'shared', 'js', 'campaign', 'present.js'), 'utf8');
    const pageJs = readFileSync(join(gmDir, 'present.js'), 'utf8');
    const setting = readFileSync(join(repoRoot, 'shared', 'js', 'campaign', 'setting.js'), 'utf8');
    const dash = readFileSync(appPath('dashboard.js'), 'utf8');
    const css = readFileSync(join(appDir, 'styles.css'), 'utf8');
    check('the page loads the shared room view before its own half',
      presentHtml.indexOf('<script src="/shared/js/campaign/core.js"') > 0
        && presentHtml.indexOf('<script src="/shared/js/campaign/core.js"')
          < presentHtml.indexOf('<script src="/shared/js/campaign/present.js"')
        && presentHtml.indexOf('<script src="/shared/js/campaign/present.js"')
          < presentHtml.indexOf('<script src="present.js"'));
    check('and the page\'s half sends no write of its own', !/method: '(PATCH|POST|PUT|DELETE)'/.test(pageJs));

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

    // ── Show to table (The Table, phase 2) ──
    // A second button that reaches past the GM's screen - to the TV and every
    // seated phone - and so the same rule as Reveal: one control each, never
    // a key, never a page turn. Paging previews for the GM alone; show() may
    // repaint what the table is looking at, and sends nothing. And Show is not
    // Reveal: it posts to the table, never PATCHes the picture.
    const toTable = functionBody(presentJs, 'function showToTable()');
    const clearT = functionBody(presentJs, 'function clearTable()');
    const tableWrite = functionBody(presentJs, 'async function tableWrite(path, body)');
    check('present.js has Show to table and Clear to read', !!toTable && !!clearT && !!tableWrite);
    check('Show posts to the table route and nowhere else',
      !!toTable && /tableWrite\('table\/show', T\.current\)/.test(toTable) && !/toggleReveal|PATCH/.test(toTable)
        && !!clearT && /tableWrite\('table\/clear', \{\}\)/.test(clearT));
    check('and the only POST in the file is the table\'s',
      (presentJs.match(/method: 'POST'/g) || []).length === 1 && !!tableWrite && /method: 'POST'/.test(tableWrite));
    const wiredTo = (fn) => [...presentJs.matchAll(new RegExp(`\\$\\('([\\w-]+)'\\)\\.addEventListener\\('\\w+', ${fn}\\)`, 'g'))].map((m) => m[1]);
    check('each is wired to its own button and nothing else',
      wiredTo('showToTable').join() === 'table-show' && wiredTo('clearTable').join() === 'table-clear',
      `${wiredTo('showToTable')} / ${wiredTo('clearTable')}`);
    check('paging does not show a picture to the table',
      !!show && !/showToTable|tableWrite/.test(show) && !!goTo && !/showToTable|tableWrite/.test(goTo));
    const presentPages = [presentHtml, readFileSync(join(repoRoot, 'apps', 'marvel-heroes', 'gm', 'present.html'), 'utf8')];
    check('both games\' Present pages have the table controls, hidden until a table is open',
      presentPages.every((h) => /<span class="present-table" id="table" hidden>/.test(h)
        && h.includes('id="table-show"') && h.includes('id="table-clear"') && h.includes('id="table-on"')));
    check('a city can be shown too, through the shared half',
      /mcPresent\.offer\(\{ kind: 'city', id: cityId \}, c\.campaign_id\)/.test(pageJs));

    // The keys: arrows, and the two a presenter's clicker sends. NOT the space
    // bar - space activates whatever button has focus, and the button most
    // likely to have it on this page is the one that reveals.
    const fromKeydown = presentJs.slice(presentJs.indexOf("addEventListener('keydown'"));
    const keyBlock = fromKeydown.slice(0, fromKeydown.indexOf('});'));
    check('the keydown handler is readable', keyBlock.length > 0 && keyBlock.length < 1200);
    check('arrows and a clicker move through the page',
      /ArrowRight/.test(keyBlock) && /ArrowLeft/.test(keyBlock)
      && /PageDown/.test(keyBlock) && /PageUp/.test(keyBlock));
    check('Escape leaves', /e\.key === 'Escape'\) leave\(\)/.test(keyBlock)
      && /function leave\(\) \{ O\.leave\(\); \}/.test(presentJs) && /function leave\(\)/.test(pageJs)
      && /mcPresent\.start\(\{[\s\S]{0,200}\bleave,/.test(pageJs));
    check('and no key press reveals anything',
      !/toggleReveal/.test(keyBlock) && !/' '/.test(keyBlock) && !/Spacebar|'Space'/.test(keyBlock));
    check('nor puts one on the table, or clears it', !/showToTable|clearTable|tableWrite/.test(keyBlock));

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
    // Both halves: neither writes markup, and the page loads no escaping
    // helper - the room view is why the shared module takes no ui adapter.
    check('the page writes no markup',
      !/\.innerHTML/.test(presentJs) && !/\.innerHTML/.test(pageJs) && !/<script[^>]+ui\.js/.test(presentHtml));
    check('and the caption is set as text', /\$\('caption'\)\.textContent/.test(presentJs));
    check('it reads the GM-only entry endpoint',
      /api\(`campaigns\/\$\{campaignId\}\/entries\/\$\{entryId\}`\)/.test(presentJs));
    // The shared half reaches its own group's API through the base the page
    // passes, never a hard-coded one.
    check('and through the base the page hands it',
      /api = global\.mcCampaign\.client\(opts\.base\)/.test(presentJs) && !/\/api\/[a-z-]+\//.test(presentJs)
        && /base: '\/api\/character-creator'/.test(pageJs));
    // A City Creator city (?city_id=, Phase 4c) is shown from the SERVER's
    // player view and nothing else - never the G.M.'s whole city, which this
    // page would then have to hide parts of. Drawn with DOM calls, so the
    // no-markup check above still covers it, and it adds no write.
    const cityPart = pageJs.slice(pageJs.indexOf('async function loadCity()'), pageJs.indexOf('mcPresent.start('));
    const calls = (s) => (s.match(/\bapi\(`/g) || []).length;
    check('a city is shown from the players\' view, and only from it',
      /api\(`cities\/\$\{cityId\}\/view`\)/.test(cityPart) && !/api\(`cities\/\$\{cityId\}`\)/.test(pageJs)
        // present.js's three: the entry, Reveal's PATCH, and the table's status
        // (The Table, phase 2). Show and Clear go through tableWrite(path).
        && calls(pageJs) === 1 && calls(presentJs) === 3, `${calls(pageJs)} + ${calls(presentJs)} api() calls`);

    // ── the way in, and the way back ──
    check('the setting view offers Present on a picture and on a page',
      /presentUrl\(i\.id\)/.test(setting) && /presentUrl\(\)/.test(setting));
    check('and the link carries the campaign and the page',
      /\$\{S\.presentHref\}\?campaign_id=\$\{encodeURIComponent\(cid\(\)\)\}&entry_id=/.test(setting)
        && /C\.setting\.html\(\{ presentHref: 'present\.html' \}\)/.test(dash));
    // Leaving lands on the page that was being presented rather than at the
    // top of the roster, which takes both ends: present.js names the page in
    // the URL it goes back to, and the dashboard opens what it is handed.
    check('leaving returns to the page it was presenting',
      /q\.set\('entry_id', entryId\)/.test(pageJs) && /'\/apps\/gm-tools\/'/.test(pageJs));
    check('and the dashboard reopens that page',
      /const openEntryId = /.test(dash) && /if \(D\.isGm && openEntryId\) await C\.setting\.open\(openEntryId\)/.test(dash));

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

  // ---------- The campaign views are shared, and style nothing ----------
  // The notes, people, handouts, setting pages, ledger and present mode live in
  // shared/js/campaign/ so every game's campaign and GM pages use one copy, each
  // in its own look: the Palladium pages in this app's stylesheet, the Marvel
  // app in its standalone one. That holds only while the views carry NO style
  // of their own and reach nothing that belongs to one game - which is what a
  // quick fix inside one of them would quietly undo, so it is asserted here.
  section('The campaign views are shared, and style nothing');
  {
    const dir = join(repoRoot, 'shared', 'js', 'campaign');
    const files = readdirSync(dir).filter((f) => f.endsWith('.js')).sort();
    check('the views are all there',
      ['core.js', 'downscale.js', 'handouts.js', 'ledger.js', 'notes.js', 'people.js', 'present.js', 'setting.js']
        .every((f) => files.includes(f)), files.join(', '));
    // Code only: the files explain in comments what they must not do.
    const code = Object.fromEntries(files.map((f) => [f, readFileSync(join(dir, f), 'utf8')
      .replace(/\/\*[\s\S]*?\*\//g, '').replace(/^\s*\/\/.*$/gm, '')]));
    const offenders = (re) => files.filter((f) => re.test(code[f])).join(', ');

    check('no view writes a style', !offenders(/\bstyle=|\.style\.|<style|<link/),
      offenders(/\bstyle=|\.style\.|<style|<link/));
    // Every class a view emits is `mc-`, so a game styles all of them and none
    // leans on a class some other stylesheet happens to define. Read from the
    // class attributes and className assignments, with the string literals
    // inside a ${...} counted as the classes they are.
    const classTokens = (src) => {
      const out = [];
      for (const [, attr] of src.matchAll(/class="((?:[^"$]|\$\{[^}]*\})*)"/g)) {
        for (const [, lit] of attr.matchAll(/\$\{[^}]*?'([^']*)'[^}]*\}/g)) out.push(...lit.split(/\s+/));
        out.push(...attr.replace(/\$\{[^}]*\}/g, ' ').split(/\s+/));
      }
      for (const [, rhs] of src.matchAll(/className = ([^;]+);/g)) {
        for (const [, lit] of rhs.matchAll(/'([^']*)'/g)) out.push(...lit.split(/\s+/));
      }
      return out.filter(Boolean);
    };
    const tokens = files.flatMap((f) => classTokens(code[f]).map((t) => [f, t]));
    const foreign = tokens.filter(([, t]) => !t.startsWith('mc-')).map(([f, t]) => `${f}: ${t}`);
    check('and every class it emits is an mc- class', tokens.length > 100 && !foreign.length,
      foreign.join('; ') || `${tokens.length} class tokens read`);
    // The other direction, for THIS game: every mc- class is styled here, or
    // is on the short list of hooks nothing in this look needs to paint.
    // `mc-on` marks the setting page that is open, which the Palladium pages
    // have never coloured.
    const UNSTYLED = new Set(['mc-on']);
    const pal = readFileSync(join(appDir, 'styles.css'), 'utf8') + readFileSync(join(repoRoot, 'shared', 'styles.css'), 'utf8');
    const emitted = [...new Set(tokens.map(([, t]) => t))];
    const unstyled = emitted.filter((c) => !UNSTYLED.has(c) && !new RegExp(`\\.${c}(?![\\w-])`).test(pal));
    check('and the Palladium stylesheet styles each one', !unstyled.length, unstyled.join(', '));

    // The page's adapter is the only road to its helpers: no view calls ui.js,
    // a native dialog, or another game's globals by name.
    // A BARE call: `M.ctx.ui.escJs(v)` is the adapter's, and is the point.
    const reach = /(?<![.\w])(escHtml|escJs|openModal|closeModal|alert|confirm|prompt)\(/;
    check('no view reaches ui.js or a native dialog except through the adapter', !offenders(reach), offenders(reach));
    // Server code stays per group, so no view names a group's API: every URL
    // is built from the base the page passes.
    check('and no view names an API of its own', !offenders(/\/api\//), offenders(/\/api\//));
    for (const [page, script] of [['campaign', 'campaign.js'], ['gm-tools', 'dashboard.js']]) {
      const src = readFileSync(join(repoRoot, 'apps', page, script), 'utf8');
      check(`${script} hands the views this group's API and its adapter`,
        /C\.init\(\{\s*base: '\/api\/character-creator', campaignId,/.test(src)
          && /modal: \(text\) => Promise\.resolve\(confirm\(text\)\)/.test(src)
          && /toast: \(text\) => alert\(text\)/.test(src));
    }
    // The views' request helper answers a failure the way this app's api()
    // does, so a caller reading err.status or err.detail (a 409's code, a
    // 422's violations) behaves the same whichever one it was handed.
    const appApi = readFileSync(join(appDir, 'js', 'api.js'), 'utf8');
    const failure = [/const err = new Error\(data\.error \|\| \('API ' \+ res\.status\)\);/,
      /err\.status = res\.status;/, /err\.detail = data;/];
    check('and its requests fail the way api() does',
      failure.every((re) => re.test(code['core.js']) && re.test(appApi)));
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
      // Exactly one mount, inside a function the render calls only behind isGm
      // - in the page's markup on the dashboard, and on the campaign page as
      // the hook the shared people view places under its roster.
      const mountFn = (js.match(/function (\w+)\(\) \{\s*return npcSheets\.mount\(/) || [])[1];
      check(`${dir} mounts it once, and only for the G.M.`,
        !!mountFn && (js.match(/npcSheets\.mount\(/g) || []).length === 1
          && (js.match(new RegExp(`(?<!function )\\b${mountFn}\\(\\)`, 'g')) || []).length === 1
          && js.includes(`D.isGm ? ${mountFn}() : ''`), mountFn || 'no mount function');
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
