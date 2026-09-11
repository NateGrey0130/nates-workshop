-- BOOK-INGEST-AUDIT F57: tag every spell with the tradition it belongs to, and
-- give the four classes that reach their OWN tradition through a level-gated
-- pick an allowance for it.
--
-- One-off data script, run once per environment, after migration 055.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzzzzz-f57-spell-traditions.sql
--
-- FILENAME SORT: this must run after every data script that inserts a spell and
-- after the four class scripts it edits, so a clean rebuild tags the rows the
-- inserts created. The z-tier's last files before it are zzzzzzzzz-f4*; f57
-- sorts after all of them.
--
-- THE FAMILIES are the prefixed ones the catalog already names, plus the shaman
-- spells, which are unprefixed and identified by their book. Counted --remote
-- on 2026-09-10, before any tag existed:
--
--   warlock    Air: / Earth: / Fire: / Water:     231
--   ocean      Ocean:                              41
--   dolphin    Dolphin:                            10
--   spellsong  Spellsong:                          21
--   cloud      Clouds of <category>:               58
--   shaman     Rifts World Book 15: Spirit West    34   (unprefixed)
--
-- NOT TAGGED, deliberately: Wormwood's level-0 prayers and Underseas' two
-- unprefixed Korallyte spells. The proposal names the prefixed families and the
-- shaman spells, and three classes whose level-up grants are uncapped (apok,
-- wormspeaker, wormwood-priest-of-light) reach the prayers that way today.
--
-- THE FOUR CLASSES. audit-premise-auditor ran the real grant functions over
-- production (2026-09-10) and found exactly four classes whose OWN tradition is
-- reached through a level-gated or uncapped pick rather than a named list, so
-- tagging would have stripped it from them at level-up:
--
--   ocean-wizard, nautyll-koral-shaper       start from a named Ocean list, then
--                                            level up through
--                                            spells_per_level_levels
--   lyn-srial-sky-knight, lyn-srial-cloudweaver   start from named Cloud lists,
--                                            then level up with no cap at all
--
-- Each gets magic.spell_traditions_allowed, inserted directly after its
-- `magic:` / `type: "spell"` opening - the one place all four blocks share.

UPDATE spells SET tradition = 'warlock'
 WHERE tradition IS NULL
   AND (name LIKE 'Air:%' OR name LIKE 'Earth:%' OR name LIKE 'Fire:%' OR name LIKE 'Water:%');
UPDATE spells SET tradition = 'ocean'     WHERE tradition IS NULL AND name LIKE 'Ocean:%';
UPDATE spells SET tradition = 'dolphin'   WHERE tradition IS NULL AND name LIKE 'Dolphin:%';
UPDATE spells SET tradition = 'spellsong' WHERE tradition IS NULL AND name LIKE 'Spellsong:%';
UPDATE spells SET tradition = 'cloud'     WHERE tradition IS NULL AND name LIKE 'Clouds of %:%';
UPDATE spells SET tradition = 'shaman'
 WHERE tradition IS NULL AND source_book LIKE 'Rifts World Book 15: Spirit West%';

UPDATE imported_classes
   SET markdown = replace(markdown,
         char(10) || 'magic:' || char(10) || '  type: "spell"' || char(10),
         char(10) || 'magic:' || char(10) || '  type: "spell"' || char(10)
           || '  spell_traditions_allowed: ["ocean"]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id IN ('ocean-wizard', 'nautyll-koral-shaper')
   AND instr(markdown, 'spell_traditions_allowed') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         char(10) || 'magic:' || char(10) || '  type: "spell"' || char(10),
         char(10) || 'magic:' || char(10) || '  type: "spell"' || char(10)
           || '  spell_traditions_allowed: ["cloud"]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id IN ('lyn-srial-sky-knight', 'lyn-srial-cloudweaver')
   AND instr(markdown, 'spell_traditions_allowed') = 0;

-- Read the result back. Every want is the count measured before the tags.
SELECT 'warlock spells tagged' AS assertion, count(*) AS got, 231 AS want FROM spells WHERE tradition = 'warlock';
SELECT 'ocean spells tagged' AS assertion, count(*) AS got, 41 AS want FROM spells WHERE tradition = 'ocean';
SELECT 'dolphin spells tagged' AS assertion, count(*) AS got, 10 AS want FROM spells WHERE tradition = 'dolphin';
SELECT 'spellsong spells tagged' AS assertion, count(*) AS got, 21 AS want FROM spells WHERE tradition = 'spellsong';
SELECT 'cloud spells tagged' AS assertion, count(*) AS got, 58 AS want FROM spells WHERE tradition = 'cloud';

SELECT 'shaman spells tagged' AS assertion, count(*) AS got, 34 AS want FROM spells WHERE tradition = 'shaman';

SELECT 'no prefixed family row is left untagged' AS assertion, count(*) AS got, 0 AS want
  FROM spells WHERE tradition IS NULL
   AND (name LIKE 'Air:%' OR name LIKE 'Earth:%' OR name LIKE 'Fire:%' OR name LIKE 'Water:%'
        OR name LIKE 'Ocean:%' OR name LIKE 'Dolphin:%' OR name LIKE 'Spellsong:%' OR name LIKE 'Clouds of %:%');

SELECT 'the four classes carry their allowance' AS assertion, count(*) AS got, 4 AS want
  FROM imported_classes
 WHERE class_id IN ('ocean-wizard', 'nautyll-koral-shaper', 'lyn-srial-sky-knight', 'lyn-srial-cloudweaver')
   AND instr(markdown, 'spell_traditions_allowed: [') > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzzz-f57-spell-traditions.sql');
