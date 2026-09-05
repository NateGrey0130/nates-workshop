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

import { appDir, repoRoot, check, section, wantSection } from '../harness.mjs';
import { fixedFormulaValue } from '../../js/dice.js';
import { parseClassMarkdown } from '../../js/parser.js';

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
  'The wizard rail',
  'The GM dashboard',
  'The printed sheet',
  'Play mode is a mode, not a layout',
  'Trackable resources',
  'The session log',
  'Two people, one character',
  'The front door agrees with the rooms',
  'Changes that could not be sent',
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
    const sheet = readFileSync(join(appDir, 'sheet.js'), 'utf8');
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
    const src = readFileSync(join(appDir, 'sheet.js'), 'utf8')
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
    check('and it is asked for steppers, which CSS then gates',
      /poolCard\(key, label, c\[key \+ '_current'\], c\[key \+ '_max'\], w, true\)/.test(src),
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
    const src = readFileSync(join(appDir, 'sheet.js'), 'utf8')
      + readFileSync(join(appDir, 'js', 'sheet-layout.js'), 'utf8');
    const css = readFileSync(join(appDir, 'styles.css'), 'utf8');
    const html = readFileSync(join(appDir, 'sheet.html'), 'utf8');

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
    check('and both come back on a phone',
      /@media \(max-width: 820px\) \{[\s\S]*?\.tabbar \{ display: flex; \}[\s\S]*?\.tabpanel \{ display: none; \}/.test(css),
      'below 820px the tabs no longer return');

    // Column assignment. Every box the body holds must be placed.
    const colBlock = src.slice(src.indexOf('const BOX_COL'), src.indexOf('};', src.indexOf('const BOX_COL')));
    const assigned = [...colBlock.matchAll(/'?([a-z-]+)'?\s*:\s*'([abc])'/g)].map((m) => m[1]);
    check('there is a single column table', assigned.length > 0, 'BOX_COL is gone');

    // Titles come from box('...') calls; the name header is a template literal
    // and is deliberately unplaced, so only quoted titles are required to map.
    const titles = [...src.matchAll(/\bbox\('([^']+)'/g)].map((m) => m[1]);
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
    const sheet = readFileSync(join(appDir, 'sheet.js'), 'utf8');
    const layout = readFileSync(join(appDir, 'js', 'sheet-layout.js'), 'utf8');
    const html = readFileSync(join(appDir, 'sheet.html'), 'utf8');

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
    check('and sheet.js supplies it in one place, not seven',
      /const paintPool = \(key\) => sheetLayout\.paintPool\(key, C\.data[^)]*\);/.test(sheet),
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
    const sheet = readFileSync(join(appDir, 'sheet.js'), 'utf8');
    check('and neither page keeps its own copy',
      !/function sizeSticky\(/.test(sheet) && !/function sizeSticky\(/.test(app),
      'a page still defines its own sizeSticky');
    for (const page of ['index.html', 'sheet.html']) {
      check(`${page} loads it`,
        readFileSync(join(appDir, page), 'utf8').includes('js/sticky.js'),
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
  section('The GM dashboard');
  {
    const js = readFileSync(join(appDir, 'dashboard.js'), 'utf8');
    const css = readFileSync(join(appDir, 'styles.css'), 'utf8');
    const html = readFileSync(join(appDir, 'dashboard.html'), 'utf8');

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
    check('and the display face, like every other numeric column',
      /var\(--font-display\)/.test(pools) && /font-stretch: 75%/.test(pools),
      'the pools column is the one numeric column still on the body face');
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
    const sheet = readFileSync(join(appDir, 'sheet.js'), 'utf8');
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
    const sheet = readFileSync(join(appDir, 'sheet.js'), 'utf8');
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
    const sheet = readFileSync(join(appDir, 'sheet.js'), 'utf8');
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
    const sheet = readFileSync(join(appDir, 'sheet.js'), 'utf8');

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

    // The sheet's Save is the write most likely to clobber someone: it sends the
    // whole editable sheet at once.
    check('the sheet sends the version it loaded',
      /body\.expect_updated_at = C\.data\?\.updated_at/.test(sheet),
      'Save still overwrites blindly');
    check('and asks before throwing away what is on screen',
      /err\.status === 409 && err\.detail\?\.conflict/.test(sheet) && /confirm\(msg\)/.test(sheet),
      'a conflict either reloads over the typing or reports as a generic failure');
  }

  // ---------- The front door agrees with the rooms ----------
  // index.html is the ONE page that does not load /shared/styles.css - it is
  // deliberately self-contained - so it carries its own copy of the palette under
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
    const shared = readFileSync(join(repoRoot, 'shared', 'styles.css'), 'utf8');

    // Comments first: shared/styles.css records its measured contrast ratios
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
  }

  // ---------- Changes that could not be sent ----------
  // A pool change made with no network stays on screen and waits, instead of
  // rolling back. What this is NOT is offline support: nothing here serves the
  // page, so a tab closed without a connection will not open again. The queue
  // survives a drop and a reload with the tab open, and that is the whole claim.
  section('Changes that could not be sent');
  {
    const queue = readFileSync(join(appDir, 'js', 'play-queue.js'), 'utf8');
    const sheet = readFileSync(join(appDir, 'sheet.js'), 'utf8');
    const layout = readFileSync(join(appDir, 'js', 'sheet-layout.js'), 'utf8');
    const css = readFileSync(join(appDir, 'styles.css'), 'utf8');
    const html = readFileSync(join(appDir, 'sheet.html'), 'utf8');
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

    // A REFUSAL AND A SILENCE ARE DIFFERENT THINGS.
    check('a server refusal still rolls back',
      /if \(err\.status === undefined && await queuePoolChange/.test(sheet),
      'anything that fails is queued, including changes the server rejected on merit');
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
  }

  // ---------- The codex ----------
  // Plan 20's second half: every spell and psionic power with its text, for the
  // ones a character does NOT hold. A seventh page, read-only by construction.
  section('The codex');
  {
    const html = readFileSync(join(appDir, 'codex.html'), 'utf8');
    const js = readFileSync(join(appDir, 'codex.js'), 'utf8');
    const css = readFileSync(join(appDir, 'styles.css'), 'utf8');
    const sheetHtml = readFileSync(join(appDir, 'sheet.html'), 'utf8');
    const wizardHtml = readFileSync(join(appDir, 'index.html'), 'utf8');
    const sheet = readFileSync(join(appDir, 'sheet.js'), 'utf8');

    check('the page exists and loads its script',
      /src="codex\.js"/.test(html) && /js\/api\.js/.test(html), 'codex.html does not load codex.js');

    // Read-only is the security posture AND the reason it can be a player page
    // at all: there is no write path to get wrong. Asserted against the file
    // rather than trusted, because adding one would be a one-line change.
    check('it is read-only by construction',
      !/method:\s*'(POST|PATCH|PUT|DELETE)'/i.test(js) && !/jsonReq\(/.test(js),
      'codex.js has grown a write path; it is served to every authenticated player');
    check('and it asks for its own route, not the boot payload',
      /api\('codex'\)/.test(js) && !/api\('catalogs'\)/.test(js),
      'the codex is loading /catalogs, which is the payload plan 20 kept it out of');

    // THE TRAP: .tabbar is display:none above 820px, because the SHEET's tabs
    // are a narrow-screen affordance. Reusing the class without this rule makes
    // the codex's tabs vanish on a desktop, which is where you browse a codex.
    check('its tabs survive at desktop width',
      /\.tabbar\.codex-tabs \{ display: flex; \}/.test(css),
      '.tabbar is display:none above 820px and the codex would show no tabs there');

    // Same lesson as .power-toggle on the sheet: the shared print block hides
    // every button, and the codex row IS a button. A codex is a reference
    // document, so unlike the sheet it prints its prose.
    check('and its rows print, being a reference document',
      /\.codex-head \{ display: grid !important;/.test(css),
      'the blanket button rule leaves the printed codex as stat blocks with no names');

    check('the sheet points at it from the powers tab',
      /codex\.html/.test(sheet), 'nothing on the sheet mentions the codex');
    check('and both pages carry a header link',
      /codex\.html/.test(sheetHtml) && /codex\.html/.test(wizardHtml),
      'the codex is reachable only by typing the URL');
  }
}
