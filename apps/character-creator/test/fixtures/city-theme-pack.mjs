// A City Creator theme pack for the checks: every line carries [W], so a draw
// says where it came from. Written for the checks alone - real packs come
// from the five AI calls (themePrompt in apps/city-creator/js/city-engine.js).
// Shared by checks/city-creator.mjs and regression.mjs's players'-view leak
// check, which needs a theme the engine accepts.

import { THEME_TABLES } from '../../../city-creator/js/city-engine.js';

export const W = (what, n = 12) => Array.from({ length: n }, (_, i) => `[W] ${what} ${i + 1}`);

// For a Palladium Fantasy city. It names the Wolfen and gives lines for the
// dwarves too - which the engine must throw away, since the theme does not
// name them.
export const westPack = () => ({
  prompt: 'An Old West boomtown on the frontier, where the Wolfen run the cattle',
  title: 'Old West boomtown',
  tables: Object.fromEntries(THEME_TABLES.map((k) => [k, k === 'RUMOURS'
    ? W('rumour', 11).map((l, i) => (i % 2 ? `${l} about {npc}` : l)).concat(['[W] they say {shop} waters the whiskey'])
    : W(k.toLowerCase())])),
  shopTypes: [
    { label: 'Saloon', stockAs: 'Tavern', names: ['Saloon', 'Bar', 'Watering Hole'], specialties: W('saloon special', 3) },
    { label: 'Gunsmith', stockAs: 'Smithy', names: ['Guns', 'Arms', 'Gunworks'], specialties: W('gun special', 3) },
    { label: 'Livery', stockAs: 'Stable', names: ['Livery', 'Corral', 'Stables'], specialties: W('livery special', 3) },
  ],
  roleOcc: { '[W] npc_roles 1': 'soldier', '[W] npc_roles 2': 'merchant' },
  mapStyle: 'rail',
  overviewExtras: [{ label: 'Law', lines: W('law', 4) }],
  raceLines: {
    wolfen: { quirks: W('wolfen quirk', 2) },
    dwarf: { quirks: W('dwarf quirk', 2) },   // dwarves are not named: thrown away
  },
});
