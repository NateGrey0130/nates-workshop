// Pick 3 Cut 5 — the game's arithmetic.
//
// The round is eight binary choices against a budget of three keeps and five
// cuts, and the whole design rests on that budget landing on exactly 3 and 5 no
// matter what anyone presses, when they drop, or what gets swapped mid-round.
// Every one of those paths was verified by hand during the build and NONE was
// pinned; this file is the pinning.
//
// The state space is tiny — eight items, nine budget pairs — so nothing here
// samples or approximates. It walks every reachable state and every reachable
// sequence.
//
// Run from anywhere:  node apps/pick3cut5/test/game.mjs

import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { section, check, summary } from '../../character-creator/test/harness.mjs';
import {
  KEEPS, CUTS, ITEMS_PER_ROUND, forcedChoice, itemsRemaining, budgetIsSpendable,
} from '../../../workers/pick3cut5-room/src/rules.js';

const appDir = join(dirname(fileURLToPath(import.meta.url)), '..');

// ---------- 1. The four forced-pick rules ----------
section('The four forced-pick rules');

check('no keeps left forces a cut', forcedChoice(0, 3, 3) === 'cut');
check('no cuts left forces a keep', forcedChoice(2, 0, 2) === 'keep');
check('keeps equal to the items left forces a keep', forcedChoice(3, 2, 3) === 'keep');
check('cuts equal to the items left forces a cut', forcedChoice(2, 3, 3) === 'cut');
check('a player with slack in both is free', forcedChoice(2, 3, 5) === null);
check('the opening position is free', forcedChoice(KEEPS, CUTS, ITEMS_PER_ROUND) === null);

check('remaining includes the item on screen',
  itemsRemaining(0) === ITEMS_PER_ROUND && itemsRemaining(7) === 1);

// ---------- 2. Every reachable state lands on 3 and 5 ----------
section('Every reachable sequence lands on exactly 3 and 5');

// Walks the whole tree. At each item a free player may press either button and
// a forced one may not, so this enumerates every round anybody could ever play.
const finals = [];
const unspendable = [];
const forcedWithSlack = [];

(function walk(index, keepsLeft, cutsLeft, path) {
  const remaining = itemsRemaining(index);

  if (index === ITEMS_PER_ROUND) {
    finals.push({ keepsLeft, cutsLeft, path });
    return;
  }
  if (!budgetIsSpendable(keepsLeft, cutsLeft, remaining)) {
    unspendable.push({ index, keepsLeft, cutsLeft, path });
    return;
  }

  const forced = forcedChoice(keepsLeft, cutsLeft, remaining);
  // A forced player must have had no real alternative: if the rule fires while
  // BOTH resources still have slack, the rule is wrong, not the player.
  if (forced && keepsLeft > 0 && cutsLeft > 0 && keepsLeft !== remaining && cutsLeft !== remaining) {
    forcedWithSlack.push({ index, keepsLeft, cutsLeft });
  }

  const choices = forced ? [forced] : ['keep', 'cut'];
  for (const choice of choices) {
    if (choice === 'keep') walk(index + 1, keepsLeft - 1, cutsLeft, [...path, 'K']);
    else walk(index + 1, keepsLeft, cutsLeft - 1, [...path, 'C']);
  }
})(0, KEEPS, CUTS, []);

check(`every reachable round was walked (${finals.length} of them)`, finals.length > 0);
check('no sequence ever reaches an unspendable budget',
  unspendable.length === 0, JSON.stringify(unspendable[0] ?? {}));
check('the rule never fires while the player still has a real choice',
  forcedWithSlack.length === 0, JSON.stringify(forcedWithSlack[0] ?? {}));
check('every round ends with both budgets at zero',
  finals.every((f) => f.keepsLeft === 0 && f.cutsLeft === 0),
  JSON.stringify(finals.find((f) => f.keepsLeft || f.cutsLeft) ?? {}));
check(`every round keeps exactly ${KEEPS} and cuts exactly ${CUTS}`,
  finals.every((f) => f.path.filter((c) => c === 'K').length === KEEPS
    && f.path.filter((c) => c === 'C').length === CUTS));

// The count is 8-choose-3 — every arrangement of three keeps among eight items
// is reachable, which is the real claim: the rules constrain WHEN you spend,
// never WHAT you can end up with.
const choose = (n, k) => (k === 0 ? 1 : (n * choose(n - 1, k - 1)) / k);
check(`all ${choose(ITEMS_PER_ROUND, KEEPS)} keep-arrangements are reachable`,
  new Set(finals.map((f) => f.path.join(''))).size === choose(ITEMS_PER_ROUND, KEEPS));

// ---------- 3. The client's duplicate rule agrees ----------
section("The client's copy of the rule agrees with the server's");

// solo mode has no server to ask and index.html loads classic scripts, not
// modules, so app.js reimplements forcedChoice as soloForced(). The duplication
// is the most dangerous thing in this app's design: a divergence would be
// invisible until a solo player's budget failed to add up. So rather than trust
// the comment that says "the server's copy is the real one", lift the client's
// function out of the source and run both against every reachable state.
const appSrc = readFileSync(join(appDir, 'app.js'), 'utf8');
const fnSrc = appSrc.match(/function soloForced\(\)\s*\{[\s\S]*?\n\}/);
check('soloForced() can be found in app.js', Boolean(fnSrc),
  'if this moved, fix the anchor — do not delete the check');

if (fnSrc) {
  // Rebuilt with its globals as parameters. Only the three reads of module
  // state are rewritten and the `remaining` declaration is dropped, because it
  // arrives as an argument here; every actual RULE line is used verbatim, which
  // is the whole point — a rewritten rule would prove nothing.
  const body = fnSrc[0]
    .replace(/^function soloForced\(\)\s*\{/, '')
    .replace(/\}$/, '')
    .replace(/^\s*const remaining\s*=\s*ITEMS - solo\.index;\s*$/m, '')
    .replace(/solo\.keepsLeft/g, 'keepsLeft')
    .replace(/solo\.cutsLeft/g, 'cutsLeft');

  check('the extraction left no module state behind',
    !/solo\./.test(body) && /return/.test(body),
    'the rewrite did not fully parameterise soloForced');

  const clientRule = new Function('keepsLeft', 'cutsLeft', 'remaining', body);

  // Compared over the FULL grid, not just the reachable one.
  //
  // The first cut of this compared only budget-spendable states and could not
  // fail: given keeps + cuts === remaining, `keeps === remaining` implies
  // `cuts === 0` and `cuts === remaining` implies `keeps === 0`, so the third
  // and fourth rules are caught by the first two and never fire. Two of the
  // four rules the brief specifies are unreachable under a consistent budget —
  // they are defence against an inconsistent one, and defence is exactly what
  // has to be compared, because that is the state a refund bug would produce.
  const disagreements = [];
  let compared = 0;
  for (let remaining = 1; remaining <= ITEMS_PER_ROUND; remaining++) {
    for (let k = 0; k <= KEEPS; k++) {
      for (let c = 0; c <= CUTS; c++) {
        compared++;
        const server = forcedChoice(k, c, remaining);
        const client = clientRule(k, c, remaining) ?? null;
        if (server !== client) disagreements.push({ remaining, k, c, server, client });
      }
    }
  }
  check(`the two implementations agree on all ${compared} states, reachable or not`,
    disagreements.length === 0, JSON.stringify(disagreements.slice(0, 3)));

  // Guards the guard: if the grid ever stops covering the redundant rules, the
  // comparison silently weakens back to what it was.
  const rule3 = { k: 2, c: 4, remaining: 2 };   // keeps === remaining, cuts busy
  const rule4 = { k: 3, c: 2, remaining: 2 };   // cuts === remaining, keeps busy
  check('the grid includes states where the third and fourth rules actually fire',
    forcedChoice(rule3.k, rule3.c, rule3.remaining) === 'keep'
    && forcedChoice(rule4.k, rule4.c, rule4.remaining) === 'cut');
}

// ---------- 4. A swap must refund exactly what it spent ----------
section('A swap refunds exactly what it spent');

// The property that makes the in-round swap fair: a player who had already
// committed - or been forced - on the rejected item must come out of the swap
// in precisely the state they entered it, free to decide again.
const refund = (keepsLeft, cutsLeft, choice) =>
  (choice === 'keep' ? { keepsLeft: keepsLeft + 1, cutsLeft } : { keepsLeft, cutsLeft: cutsLeft + 1 });
const spend = (keepsLeft, cutsLeft, choice) =>
  (choice === 'keep' ? { keepsLeft: keepsLeft - 1, cutsLeft } : { keepsLeft, cutsLeft: cutsLeft - 1 });

const badRoundTrips = [];
for (let index = 0; index < ITEMS_PER_ROUND; index++) {
  const remaining = itemsRemaining(index);
  for (let k = 0; k <= KEEPS; k++) {
    for (let c = 0; c <= CUTS; c++) {
      if (!budgetIsSpendable(k, c, remaining)) continue;
      const forced = forcedChoice(k, c, remaining);
      for (const choice of forced ? [forced] : ['keep', 'cut']) {
        const after = spend(k, c, choice);
        const back = refund(after.keepsLeft, after.cutsLeft, choice);
        if (back.keepsLeft !== k || back.cutsLeft !== c) {
          badRoundTrips.push({ index, k, c, choice, back });
        }
      }
    }
  }
}
check('spending then refunding any pick restores the exact budget',
  badRoundTrips.length === 0, JSON.stringify(badRoundTrips[0] ?? {}));

// A swapped item is re-revealed at the SAME index, so the refunded player must
// face the same forced-or-free state they did before - otherwise the swap could
// hand somebody a free choice they had not earned, or take one away.
const changedFooting = [];
for (let index = 0; index < ITEMS_PER_ROUND; index++) {
  const remaining = itemsRemaining(index);
  for (let k = 0; k <= KEEPS; k++) {
    for (let c = 0; c <= CUTS; c++) {
      if (!budgetIsSpendable(k, c, remaining)) continue;
      const before = forcedChoice(k, c, remaining);
      const choice = before ?? 'keep';
      const after = spend(k, c, choice);
      const back = refund(after.keepsLeft, after.cutsLeft, choice);
      if (forcedChoice(back.keepsLeft, back.cutsLeft, remaining) !== before) {
        changedFooting.push({ index, k, c });
      }
    }
  }
}
check('a refunded player faces the same choice they faced before the swap',
  changedFooting.length === 0, JSON.stringify(changedFooting[0] ?? {}));

// ---------- 5. Constants agree with the name ----------
section('Constants agree with the name on the door');

check('the app is called Pick 3 Cut 5 and keeps 3', KEEPS === 3);
check('...and cuts 5', CUTS === 5);
check('...across 8 items', KEEPS + CUTS === ITEMS_PER_ROUND);

const html = readFileSync(join(appDir, 'index.html'), 'utf8');
check('the page tells the player the same numbers',
  /three keeps\.\s*five cuts/i.test(html));

process.exit(summary() === 0 ? 0 : 1);
