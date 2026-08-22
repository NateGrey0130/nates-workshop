-- Twenty gear prices, corrected against the pages they came from.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-rue-gear-prices.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-rue-gear-prices.sql
--
-- THIRTEEN ROWS HELD THE HIGH END OF A PRINTED RANGE. This is the same bug
-- migration 032 was written for - `cost` holds the LOW end, the number the
-- sheet spends, and `cost_note` carries the range verbatim - and these are the
-- rows that fix missed. `backfill-gear-cost-notes.sql` was deliberately
-- guarded on the stored cost ALREADY being the low end, so every row that had
-- the high end was skipped by design and stayed wrong.
--
-- TWO WERE JUST WRONG. Blanket (Heavy) at 6 against the book's 20, and Blanket
-- (Light) at 4 against 10. Not a range, not a note - transposed somewhere.
--
-- ONE IS A PAGE-BREAK ERROR. NG-101 Rail Gun carried 70,000, which is the
-- NG-202's price on the following line: the NG-101 block starts on printed
-- p270 and its Black Market Cost line falls on p271. That is the "a row
-- straddling a page break loses whatever fell on the far side" failure the
-- book-survey skill names, and here it produced a WRONG number rather than a
-- missing one, which is worse.
--
-- FOUR OCR'D PRICE LINES read `er.` where the book prints `cr.`, and were
-- invisible to a pattern requiring `cr` or `credits` - Knapsack, Knife Large,
-- Machete, Mallet, Mechanical Pencil and Sunglasses or Goggles among them.
-- Three of those turned out to be wrong and three merely undocumented.
--
-- WHAT IS DELIBERATELY NOT HERE:
--
--   Hammer (tool) carries 7 and the book prints "Hammer (average, metal):
--   10-20 cr." The catalog also holds Small Hammer at 10 and Small Mallet at
--   2, and there is no way to tell from a price alone which row the book's
--   entry is. Guessing would be how you get a confidently wrong catalog.
--
--   Canteen carries 20, which looked wrong until the page showed three
--   canteens priced separately - Aluminum 30, Plastic 20, 2 M.D.C. 2200. The
--   catalog holds the plastic one and is right.
--
--   Spike carries 3 against "Spikes (6, iron): 6 cr." - a pack of six, not one
--   spike. Different granularity, not a different price.
--
-- Every UPDATE is guarded on the OLD value, so a row somebody has since
-- corrected by hand is left alone and re-running does nothing.

-- Backpack, large, high quality: 100-200 cr.
UPDATE gear SET cost = 100, cost_note = '100-200 cr.'
 WHERE name = 'Backpack, large, high quality' AND cost = 200;

-- Bandoleer (with pouches and or belt loops): 12-25 cr.
UPDATE gear SET cost = 12, cost_note = '12-25 cr.'
 WHERE name = 'Bandoleer (with pouches and or belt loops)' AND cost = 25;

-- Cigarette Lighter (refillable): 10-25 cr.
UPDATE gear SET cost = 10, cost_note = '10-25 cr.'
 WHERE name = 'Cigarette Lighter (refillable)' AND cost = 25;

-- Cross/Crucifix (wood; 8-12 inches): 2-10 cr.
UPDATE gear SET cost = 2, cost_note = '2-10 cr.'
 WHERE name = 'Cross/Crucifix (wood; 8-12 inches)' AND cost = 10;

-- Cross/Crucifix (silver, 8-12 inches): 200-400 cr. (double for gold)
UPDATE gear SET cost = 200, cost_note = '200-400 cr. (double for gold)'
 WHERE name = 'Cross/Crucifix (silver; 8-12 inches)' AND cost = 400;

-- Flashlight, large: 12-20 cr.
UPDATE gear SET cost = 12, cost_note = '12-20 cr.'
 WHERE name = 'Flashlight, large' AND cost = 20;

-- Gas Mask (human-size): 50-80 cr. (half that used)
UPDATE gear SET cost = 50, cost_note = '50-80 cr. (half that used)'
 WHERE name = 'Gas Mask (human-size)' AND cost = 80;

-- Gas Mask (larger than human): 80-120 cr.
UPDATE gear SET cost = 80, cost_note = '80-120 cr.'
 WHERE name = 'Gas Mask (larger than human)' AND cost = 120;

-- Marker Pens (dozen): 6-8 cr.
UPDATE gear SET cost = 6, cost_note = '6-8 cr.'
 WHERE name = 'Marker Pens (dozen)' AND cost = 8;

-- Sunglasses (fancy or light adjusting): 100-300 cr.
UPDATE gear SET cost = 100, cost_note = '100-300 cr.'
 WHERE name = 'Sunglasses (fancy or light adjusting)' AND cost = 300;

-- Machete with canvas sheath (does 2D4 S.D.C. damage): 40-100 cr.
UPDATE gear SET cost = 40, cost_note = '40-100 cr.'
 WHERE name = 'Machete with canvas sheath' AND cost = 100;

-- Mechanical Pencil (1): 2-5 cr.
UPDATE gear SET cost = 2, cost_note = '2-5 cr.'
 WHERE name = 'Mechanical Pencil' AND cost = 5;

-- Sunglasses or Goggles (cheap): 15-50 cr.
UPDATE gear SET cost = 15, cost_note = '15-50 cr.'
 WHERE name = 'Sunglasses or Goggles (cheap)' AND cost = 50;

-- Blanket, Heavy: 20 cr.
UPDATE gear SET cost = 20
 WHERE name = 'Blanket (Heavy)' AND cost = 6;

-- Blanket, Light: 10 cr.
UPDATE gear SET cost = 10
 WHERE name = 'Blanket (Light)' AND cost = 4;

-- Black Market Cost: 55,000 credits. Good availability. (printed p270-271; 70,000 is the NG-202 on the next line)
UPDATE gear SET cost = 55000
 WHERE name = 'NG-101 Rail Gun' AND cost = 70000;

-- Correct already; the range was simply never recorded.
-- Knapsack: 50-100 cr.
UPDATE gear SET cost_note = '50-100 cr.'
 WHERE name = 'Knapsack' AND cost = 50 AND cost_note IS NULL;

-- Knife, Large (does 1D6 S.D.C. damage): 20-100 cr.
UPDATE gear SET cost_note = '20-100 cr.'
 WHERE name = 'Knife, Large' AND cost = 20 AND cost_note IS NULL;

-- Mallet (small): 2-4 cr.
UPDATE gear SET cost_note = '2-4 cr.'
 WHERE name = 'Small Mallet' AND cost = 2 AND cost_note IS NULL;

-- Priced in the book, never priced here.
-- Cigarette Lighter Fluid: 6 credits per 16 ounce can.
UPDATE gear SET cost = 6, cost_note = '6 credits per 16 ounce can'
 WHERE name = 'Cigarette Lighter Fluid' AND cost IS NULL;

-- Read the result back rather than trusting the exit code.
SELECT name, cost, cost_note FROM gear
 WHERE name IN (
  'Backpack, large, high quality',
  'Bandoleer (with pouches and or belt loops)',
  'Cigarette Lighter (refillable)',
  'Cross/Crucifix (wood; 8-12 inches)',
  'Cross/Crucifix (silver; 8-12 inches)',
  'Flashlight, large',
  'Gas Mask (human-size)',
  'Gas Mask (larger than human)',
  'Marker Pens (dozen)',
  'Sunglasses (fancy or light adjusting)',
  'Machete with canvas sheath',
  'Mechanical Pencil',
  'Sunglasses or Goggles (cheap)',
  'Blanket (Heavy)',
  'Blanket (Light)',
  'NG-101 Rail Gun',
  'Knapsack',
  'Knife, Large',
  'Small Mallet',
  'Cigarette Lighter Fluid')
 ORDER BY name;

SELECT count(*) AS with_cost_note FROM gear WHERE cost_note IS NOT NULL;
SELECT count(*) AS gear_total FROM gear;

INSERT INTO data_script_runs (filename) VALUES ('fix-rue-gear-prices.sql');
