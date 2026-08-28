#!/usr/bin/env node
// Print a commented starting point for writing a class BY HAND.
//
//   node scripts/new-class.mjs occ --name "Symbiotic Warrior" --id symbiotic-warrior \
//     --system rifts --book "Rifts Dimension Book 1: Wormwood p.64-65" > draft.md
//   node scripts/new-class.mjs rcc --name "Morphworm" --id morphworm
//
// The template itself is `apps/character-creator/js/class-template.js` and it is
// NOT new - it shipped as part of the in-app importer, which is the only thing
// that ever loaded it. This is a front door for it, added when that importer was
// retired, because deleting it along with the rest would have thrown away the
// one asset built for the workflow that replaced it.
//
// Hand-authoring is how every class in this catalog actually got written,
// including all seventeen from Wormwood. The template's own header makes the
// case better than this one can: "The comments are the point. The fiddly parts
// (`variants`, `bonuses`, skill choice-groups, gear choices) are exactly what
// nobody remembers the shape of, and they are the reason writing a class by hand
// is worth supporting at all."
//
// It is left where it is rather than moved into scripts/. It is a classic script
// exposing one global, the smoke test already loads it from that path and pins
// that both kinds parse clean on arrival, and moving it would churn those checks
// for no gain. This file loads it exactly the way the smoke test does.
//
// Everything it prints parses as-is: generate one, run class-check on it, and it
// comes back clean before you have written a word. That is deliberate - a
// template that fails validation on arrival teaches you nothing about which of
// your own edits broke it.
import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { repoRoot } from './d1-query-lib.mjs';

const argv = process.argv.slice(2);
const flag = (name, fallback = null) => {
  const i = argv.indexOf(`--${name}`);
  return i >= 0 && argv[i + 1] && !argv[i + 1].startsWith('--') ? argv[i + 1] : fallback;
};

const kind = (argv[0] || '').toLowerCase();
if (!argv.length || argv.includes('--help') || !['occ', 'rcc'].includes(kind)) {
  console.error('usage: node scripts/new-class.mjs <occ|rcc> [--name N] [--id I] [--system S] [--book B]');
  console.error('');
  console.error('  occ  a character class: attribute MINIMUMS, hit points');
  console.error('  rcc  a race: attribute DICE, usually M.D.C., and no xp_table');
  console.error('');
  console.error('The two are genuinely different shapes, which is why there are two');
  console.error('templates rather than one that would be half wrong either way.');
  process.exit(argv.includes('--help') ? 0 : 1);
}

// The template is a classic script that assigns one global, so it is loaded the
// same way the smoke test loads it rather than imported.
const src = readFileSync(join(repoRoot, 'apps', 'character-creator', 'js', 'class-template.js'), 'utf8');
const sandbox = {};
new Function('globalThis', src).call(sandbox, sandbox);
if (typeof sandbox.classTemplate !== 'function') {
  console.error('class-template.js no longer exposes classTemplate()');
  process.exit(1);
}

process.stdout.write(sandbox.classTemplate(kind, {
  name: flag('name', 'New Class'),
  id: flag('id', 'new-class'),
  system: flag('system', 'rifts'),
  sourceBook: flag('book', 'Book Title p.NN-NN'),
}));
