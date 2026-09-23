// Dice. Plain functions around one seedable generator, so a roll can be
// replayed exactly: the smoke suite runs the FEAT roller and the generator
// against fixed seeds, and a hero can later be rebuilt from the seed that made
// it. Mulberry32 - small, fast, and good enough for dice; nothing here is
// security-sensitive.

export function rng(seed) {
  let a = seed >>> 0;
  return function next() {
    a = (a + 0x6d2b79f5) >>> 0;
    let t = a;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

// A fresh seed when the caller does not care which: crypto where there is one.
export function newSeed() {
  if (globalThis.crypto?.getRandomValues) return globalThis.crypto.getRandomValues(new Uint32Array(1))[0];
  return Math.floor(Math.random() * 4294967296);
}

// A die of `sides` from a generator: 1..sides.
export const die = (next, sides) => 1 + Math.floor(next() * sides);

// Percentile dice, 1..100, the way the books read them: "00" is 100.
export const d100 = (next) => die(next, 100);

// The entry whose [lo, hi] band holds `roll`, from a list of { roll: [lo, hi] }
// or { lo, hi } entries. null when nothing covers it, which the data's own
// coverage checks make impossible for any table this app ships.
export function pick(table, roll) {
  for (const e of table) {
    const [lo, hi] = e.roll || [e.lo, e.hi];
    if (roll >= lo && roll <= hi) return e;
  }
  return null;
}
