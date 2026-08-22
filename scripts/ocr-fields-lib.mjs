// Reading a NUMBER out of a scanned sourcebook.
//
// The OCR is not hesitant about its mistakes. Measured across the cached RUE
// text, Tesseract reads "Ibs" at 91-94 percent confidence and "18.000" at
// 93-97, and only 1.3% of words in the book score under 70 - none of them the
// known misreads. Raising the DPI from 300 to 600 took one error class from 7
// occurrences to 5. Changing the engine changed nothing.
//
// So neither a better scan nor a confidence filter will find these. What finds
// them is knowing what the field is ALLOWED to be: no price is quoted in
// thousandths of a credit, no weight is measured in "Ibs", and a damage value
// is dice. These readers encode that, and they REFUSE rather than guess - a
// caller that gets null knows to look at the page.
//
// scripts/ocr-book.py repairs the same confusions once, at ingest, for the
// whole book. These exist for the cases context cannot settle in bulk, and so
// that every extraction script stops writing its own regex.

/** Digits with an OCR'd separator repaired. Not exported; the typed readers below are. */
function digits(raw) {
  return String(raw ?? '')
    .replace(/,/g, '')
    // 18.000 -> 18000. EXACTLY three digits: this book writes measurements as
    // "1.8 m" and "0.9 m", never to three places, and prints "130.101 -
    // 180,200" as one range with both separators.
    .replace(/(\d)\.(\d{3})\b/g, '$1$2')
    .replace(/(\d)\.(\d{3})\b/g, '$1$2');
}

/**
 * A price in credits, or null.
 *
 * Returns the LOW end of a range, which is the convention `gear.cost` holds and
 * `gear.cost_note` documents - an import that took the high end got eight rows
 * out of eight wrong, and thirteen more survived the fix for it.
 */
export function money(raw) {
  if (raw == null) return null;
  const s = digits(raw)
    // "20-100 er." is a price. Every occurrence in RUE follows a digit and no
    // real word does; a bare er->cr would wreck "her" and "player".
    .replace(/(?<=\d)(\s*)er\b\.?/g, '$1cr.');
  const m = s.match(/\d+/);
  return m ? Number(m[0]) : null;
}

/** True when the text quotes a range or a qualifier, so the wording is worth keeping. */
export function isVariableCost(raw) {
  const s = digits(raw);
  return /\d\s*(?:-|to)\s*\d/.test(s) || /vari|special|each|per\b|double|half/i.test(String(raw ?? ''));
}

/**
 * A weight in pounds, or null.
 *
 * `Ibs` is a capital-I misread of `lbs` and appears 105 times in the raw text
 * of one book. A lone `|` is a misread `1`, which is how "1 lb" becomes "| Ib".
 */
export function weightLbs(raw) {
  if (raw == null) return null;
  let s = digits(raw)
    .replace(/(?<![A-Za-z])[Il|]bs?(?![A-Za-z])/g, 'lbs')
    .replace(/(?<!\S)\|(?!\S)/g, '1');
  // Prefer an explicit pounds figure over the parenthesised metric conversion.
  const lb = s.match(/([\d.]+)\s*(?:lbs?|pounds?)\b/i);
  if (lb) return Number(lb[1]);
  const kg = s.match(/([\d.]+)\s*kg\b/i);
  if (kg) return Math.round(Number(kg[1]) * 2.2046 * 100) / 100;
  const bare = s.match(/[\d.]+/);
  return bare ? Number(bare[0]) : null;
}

/**
 * A dice expression, normalised, or null.
 *
 * `[D4` and `1D4` are the same roll; `2D6x 10` and `2D6x10` likewise. Anything
 * that is not dice - "Varies with missile type" - comes back null on purpose,
 * because a damage field that cannot be read is a note, not a zero.
 */
export function dice(raw) {
  if (raw == null) return null;
  const s = String(raw)
    .replace(/[\[\](){}]/g, '1')          // [D4 -> 1D4
    .replace(/\s*[xX]\s*(\d)/g, 'x$1')    // 2D6x 10 -> 2D6x10
    .replace(/\bD\b/g, 'D');
  const m = s.match(/\d+\s*[Dd]\s*\d+(?:x\d+)?(?:\s*\+\s*\d+)?/);
  return m ? m[0].replace(/\s+/g, '').toUpperCase().replace('X', 'x') : null;
}

/** True when a value mentions Mega-Damage, so `is_mega_damage` is not a guess. */
export function isMegaDamage(raw) {
  return /\bM\.?\s?D\.?(?:C\.?)?\b|mega-?damage/i.test(String(raw ?? ''));
}

/**
 * Every field reader, by the label the book prints.
 *
 * Used by an extractor so one stat block yields typed values with one call, and
 * so a new import cannot quietly invent a different rule for "Weight:".
 */
export const READERS = {
  cost: money,
  'black market cost': money,
  weight: weightLbs,
  damage: dice,
  'mega-damage': dice,
};
