// The level maths moved into the app: apps/character-creator/js/leveling.js.
//
// Both sides need it. The API levels a character up; the wizard builds one that
// STARTS above level 1 and computes the same diff before the character exists,
// and a browser cannot import anything under functions/. Re-exported rather
// than moved-and-updated so every server import here is unchanged, and so there
// is exactly one implementation of the level curve.
//
// Same arrangement as js/dice.js, which this file already reached across for.
export * from '../../../../apps/character-creator/js/leveling.js';
