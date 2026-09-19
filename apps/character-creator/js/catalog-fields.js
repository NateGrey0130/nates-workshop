// One declarative description of every editable content catalog.
//
// Imported by both the browser and the Workers runtime, like parser.js and
// dice.js. It is the single place that knows what a catalog row looks like:
//
//   - the catalog editor builds its table and its row form from `fields`
//   - the write endpoints validate and coerce against `fields`, and build their
//     SQL from it rather than from anything a caller sent
//   - the PDF importers (PRs 5-7) build their extraction prompts and review
//     tables from the same entries
//
// Adding a column means adding it here, not in four places. Adding a whole
// catalog should mean adding an entry, not writing code.
//
// FIELD TYPES
//   text      short single-line string
//   longtext  multi-line string
//   int       integer, stored as-is
//   real      decimal number
//   bool      stored as INTEGER 0/1, edited as a checkbox
//   select    one of `options`; `allowOther` keeps an unrecognised stored value
//             usable instead of silently rewriting it
//   systems   the skills.systems JSON array — NULL/absent means "both systems"
//   kv        a flat JSON object of arbitrary keys, e.g. gear.stats
//   bonuses   a class-shaped `bonuses` block, through validateBonuses. Flat
//             numbers only, unless the field says `flatOnly: false`
//   skill_list an `occ_skills`-shaped JSON list, through validateSkillEntries
//   json_list a JSON list whose entries are the shape `of` names: 'string', or
//             an object mapping each key to 'string' or 'count'. Checked here
//             and nowhere else - a list no parser owns, so there is no second
//             validator to reuse. NULL when blank or empty
//   dice      a whole number or a dice expression ("2", "1d4+1", "1d4x10"),
//             stored as TEXT, through the parser's own isDiceBonus - so it
//             accepts exactly what a `bonuses` value does
//
// `blankAs` mirrors a NOT NULL DEFAULT in the schema. Several numeric columns
// are NOT NULL DEFAULT 0, so coercing an empty form field to NULL fails the
// insert. Where the column cannot hold NULL, say what empty means instead.

import { validateBonuses, validateSkillEntries, isDiceBonus } from './parser.js';

// The creature pool grammar (js/creature-roll.js), stated where a form shows it.
const FORMULA_HELP = 'A formula: dice, whole numbers and attributes joined by + or - - '
  + '"3D6", "1D4x10", "PE+20", "PEx10". Anything else is refused when the creature is rolled.';

export const CATALOGS = {
  skills: {
    table: 'skills',
    label: 'Skills',
    // What a human calls the row, and what the DB enforces uniqueness on. They
    // differ for gear, which is keyed on slug.
    displayField: 'name',
    uniqueField: 'name',
    hasSource: true,
    fields: [
      { name: 'name', label: 'Name', type: 'text', required: true },
      { name: 'category', label: 'Category', type: 'text' },
      { name: 'base', label: 'Base %', type: 'int', blankAs: 0, help: '0 means non-percentile (W.P.s, hand to hand)' },
      { name: 'per_level', label: '+% / level', type: 'int', blankAs: 0 },
      { name: 'systems', label: 'Systems', type: 'systems' },
      { name: 'source_book', label: 'Source book', type: 'text' },
      { name: 'note', label: 'Note', type: 'longtext', help: 'Oddities: "40%/30% climb/rappel", "counts as two skills"' },
      // What the skill grants beyond its percentage - Boxing is +1 attack per
      // melee and +2 P.S. Same shape as a class's `bonuses:` block, validated
      // through the same validateBonuses, so a skill cannot express a bonus a
      // class could not and derive.js needs no new cases.
      { name: 'bonuses', label: 'Bonuses', type: 'bonuses',
        help: 'JSON, flat numbers only: {"attributes":{"PS":2},"combat":{"attacks":1}}. '
          + 'Dice and S.D.C. go in Note until skill dice are rolled at acquisition' },
    ],
  },

  spells: {
    table: 'spells',
    label: 'Spells',
    displayField: 'name',
    uniqueField: 'name',
    hasSource: true,
    fields: [
      { name: 'name', label: 'Name', type: 'text', required: true },
      { name: 'level', label: 'Spell level', type: 'int', blankAs: 0 },
      { name: 'ppe', label: 'P.P.E.', type: 'int', blankAs: 0,
        help: 'The minimum cost when the spell has a schedule - see the note field.' },
      // A spell whose cost is not one number - Manipulate Objects prices by a
      // schedule. `ppe` keeps the minimum (the use button deducts it) and this
      // says the schedule in a few words. Mirrors psionics' isp_note.
      { name: 'ppe_note', label: 'P.P.E. varies', type: 'text',
        help: 'Blank for a flat cost. Otherwise the schedule in a few words.' },
      // P.P.E. burned out of the CASTER'S BASE for good - Close Rift's 2, Ley Line
      // Resurrection's 2D6 (BOOK-INGEST-AUDIT F101, migration 067). The number
      // only; when it is burned stays in the description.
      { name: 'ppe_permanent', label: 'Permanent P.P.E. from base', type: 'text',
        help: 'Blank for most spells. A number or dice, e.g. "2" or "2D6". When it applies goes in the description.' },
      { name: 'system', label: 'System', type: 'select', options: ['rifts', 'palladium-fantasy', 'nightbane', 'heroes-unlimited', 'both'],
        help: 'Blank means unrestricted — offered to characters in any system.' },
      // Stat block. Text, not numbers — books write "100 feet per level of
      // experience" and "2D6 melee rounds" as often as they write a figure.
      { name: 'range', label: 'Range', type: 'text' },
      { name: 'duration', label: 'Duration', type: 'text' },
      { name: 'damage', label: 'Damage', type: 'text' },
      { name: 'saving_throw', label: 'Saving throw', type: 'text' },
      { name: 'area_of_effect', label: 'Area of effect', type: 'text' },
      { name: 'casting_time', label: 'Casting time', type: 'text' },
      { name: 'description', label: 'Description', type: 'longtext' },
      { name: 'source_book', label: 'Source book', type: 'text' },
    ],
  },

  psionics: {
    table: 'psionic_powers',
    label: 'Psionic powers',
    displayField: 'name',
    uniqueField: 'name',
    hasSource: true,
    fields: [
      { name: 'name', label: 'Name', type: 'text', required: true },
      // allowOther: a later book may add a category the core four don't cover,
      // and a stored value must never be silently rewritten to fit the list.
      { name: 'category', label: 'Category', type: 'select', allowOther: true,
        options: ['Healing', 'Physical', 'Sensitive', 'Super'] },
      { name: 'isp', label: 'I.S.P.', type: 'int', blankAs: 0,
        help: 'The minimum cost when the power has a schedule — see the note field.' },
      // A power whose cost is not one number: Mind Bolt costs more for more
      // damage. `isp` keeps the minimum (the use button deducts it) and this
      // says the schedule in a few words.
      { name: 'isp_note', label: 'I.S.P. varies', type: 'text',
        help: 'Blank for a flat cost. Otherwise the schedule in a few words, e.g. "more for more damage".' },
      { name: 'system', label: 'System', type: 'select', options: ['rifts', 'palladium-fantasy', 'nightbane', 'heroes-unlimited', 'both'],
        help: 'Blank means unrestricted — offered to characters in any system.' },
      // Same field names as spells, so the sheet renders both the same way.
      { name: 'range', label: 'Range', type: 'text' },
      { name: 'duration', label: 'Duration', type: 'text' },
      { name: 'saving_throw', label: 'Saving throw', type: 'text' },
      { name: 'description', label: 'Description', type: 'longtext' },
      // Blank means no restriction beyond the power's category — which is what
      // most book entries actually say. Nothing enforces this yet.
      { name: 'min_tier', label: 'Minimum psychic tier', type: 'select',
        options: ['minor', 'major', 'master'],
        help: 'Only when the book states one. Blank = whatever the category already allows.' },
      { name: 'source_book', label: 'Source book', type: 'text' },
    ],
  },
  superAbilities: {
    table: 'super_abilities',
    label: 'Super abilities',
    displayField: 'name',
    uniqueField: 'name',
    hasSource: true,
    // NO cost field and NO level field, and their absence is the entire reason
    // this is not `spells` or `psionic_powers`. A Heroes Unlimited super ability
    // is a permanent trait the character simply has; the stat block below
    // describes it in use rather than pricing it. Migration 057.
    fields: [
      { name: 'name', label: 'Name', type: 'text', required: true },
      // allowOther for the same reason psionics' category has it: a later book
      // may print a division these two do not cover, and a stored value must
      // never be silently rewritten to fit the list.
      { name: 'tier', label: 'Tier', type: 'select', allowOther: true,
        options: ['minor', 'major'],
        help: 'The only division these have. Blank when the book does not say.' },
      { name: 'system', label: 'System', type: 'select', options: ['rifts', 'palladium-fantasy', 'nightbane', 'heroes-unlimited', 'both'],
        help: 'Blank means unrestricted — offered to characters in any system.' },
      // Same field names as spells and psionic powers, so the sheet renders all
      // three the same way. TEXT because books write "100 feet per level of
      // experience" as often as a number.
      { name: 'range', label: 'Range', type: 'text' },
      { name: 'duration', label: 'Duration', type: 'text' },
      { name: 'damage', label: 'Damage', type: 'text' },
      { name: 'saving_throw', label: 'Saving throw', type: 'text' },
      { name: 'description', label: 'Description', type: 'longtext' },
      { name: 'source_book', label: 'Source book', type: 'text' },
    ],
  },
  talents: {
    table: 'talents',
    label: 'Talents',
    displayField: 'name',
    uniqueField: 'name',
    hasSource: true,
    // TWO costs, and their presence is the entire reason this is not `spells`
    // or `psionic_powers`. A Nightbane Talent is bought once with a permanent
    // P.P.E. expenditure and paid for again on every activation, so either of
    // those tables would silently drop a number. Migration 063,
    // `BOOK-INGEST-AUDIT.md` F76.
    fields: [
      { name: 'name', label: 'Name', type: 'text', required: true },
      // allowOther for the reason psionics' category and super abilities' tier
      // have it: a later Nightbane sourcebook may print a third division, and a
      // stored value must never be silently rewritten to fit the list.
      { name: 'tier', label: 'Tier', type: 'select', allowOther: true,
        options: ['common', 'elite'],
        help: 'The only division the core book has. Blank when it does not say.' },
      // NOT NULL DEFAULT 0 in the schema, so blank has to mean 0 rather than
      // NULL. Every one of the core book's 25 Talents states a flat integer
      // here, which is why this is the cost that is never a schedule.
      { name: 'acquire_ppe', label: 'P.P.E. to acquire', type: 'int', blankAs: 0,
        help: 'Paid ONCE, permanently, for life - not re-spent on use.' },
      { name: 'ppe', label: 'P.P.E. to activate', type: 'int', blankAs: 0,
        help: 'The minimum, paid every activation. 0 when the book says the cost varies '
          + '- put the schedule in the next field.' },
      // The common case rather than the exception here: only three of the core
      // book's 25 Talents are a clean acquire/activate pair, and the other 22
      // state a third term - a per-minute rate, an upgrade price, or a cost
      // paid in S.D.C. Same column and same meaning as `spells.ppe_note`.
      { name: 'ppe_note', label: 'Activation cost varies', type: 'text',
        help: 'Blank for a flat cost. Otherwise the schedule in a few words, '
          + 'e.g. "plus 15 per additional minute".' },
      // An integer because the book is not: the ten level-gated Talents spell
      // it six different ways, mixing "3rd" with "third" and "fifth".
      { name: 'min_character_level', label: 'Minimum level', type: 'int',
        help: 'Blank when the Talent has no level gate, which is most of them.' },
      // Free text and not a morphus-only flag: the core book's 25 Limitations
      // blocks give four answers, one of which is saying nothing at all.
      { name: 'form_required', label: 'Form required', type: 'select', allowOther: true,
        options: ['morphus', 'facade', 'both'],
        help: 'Blank when the book states no form.' },
      { name: 'prerequisite', label: 'Prerequisite', type: 'text',
        help: 'Another Talent, or a Morphus characteristic the Nightbane must already have.' },
      { name: 'system', label: 'System', type: 'select', options: ['rifts', 'palladium-fantasy', 'nightbane', 'heroes-unlimited', 'both'],
        help: 'Blank means unrestricted — offered to characters in any system.' },
      // Same field names as spells, psionic powers and super abilities, so the
      // sheet renders all four the same way.
      { name: 'range', label: 'Range', type: 'text' },
      { name: 'duration', label: 'Duration', type: 'text' },
      { name: 'saving_throw', label: 'Saving throw', type: 'text' },
      { name: 'description', label: 'Description', type: 'longtext' },
      { name: 'source_book', label: 'Source book', type: 'text' },
    ],
  },

  // The Morphus tables: one row per ENTRY of Nightbane's 19 percentile tables
  // (printed 91-106), plus an `intro` row per table. Migration 068, survey D5.
  // READ since migration 069: a character's `second_form.results` names rows
  // by `key`, folded by js/second-form.js and loaded (renames followed through
  // catalog_redirects) by functions/.../_lib/second-form.js. The wizard's
  // generator (js/morphus.js) walks them, fetched through catalogs/traits.
  //
  // KEYED ON A STORED `key`, NOT ON A COMPOSITE. An entry is identified by
  // (table_name, roll_low, name) and `uniqueField` is one column, read as one
  // by the clash check, the rename redirect and the pair dismissal. So the row
  // stores '<table_name>: <name>' and a CHECK in the schema holds it to those
  // two columns; a save that edits one and not the other is refused. It is the
  // display field too, because a bare name is ambiguous - "Combination of Two"
  // is an entry in four tables - and a redirect filed from a display name
  // would be ambiguous the same way.
  //
  // NO `MERGE_REFS` ENTRY, for the reason vehicles gives below, and a sharper
  // one: two rows sharing a name in different tables are different entries by
  // construction, so duplicate review would propose exactly the pairs that are
  // never duplicates. And a merge has no repointing to do for a character: a
  // stored result names a KEY, which a rename's redirect already resolves.
  morphus: {
    table: 'morphus_characteristics',
    label: 'Morphus tables',
    displayField: 'key',
    uniqueField: 'key',
    hasSource: true,
    fields: [
      { name: 'key', label: 'Key', type: 'text', required: true,
        help: 'Exactly "<table>: <name>", e.g. "Canine: Were-Canine". The database refuses any other.' },
      { name: 'table_name', label: 'Table', type: 'text', required: true,
        help: 'The printed table without the word "Table": Appearance, Animal Form, Stigmata...' },
      { name: 'name', label: 'Name', type: 'text', required: true,
        help: 'The entry as printed. An intro row takes the table\'s heading, e.g. "Canine Table".' },
      // Required rather than blankAs: 0 is a real value here, the intro row's,
      // and a blank band on an effect row is a mistake rather than a default.
      { name: 'roll_low', label: 'Roll from', type: 'int', required: true,
        help: '1-100, 00 as 100. 0 on an intro row.' },
      { name: 'roll_high', label: 'Roll to', type: 'int', required: true },
      // allowOther for the reason talents' tier has it: a later book may print
      // an entry that does something these four do not name.
      { name: 'kind', label: 'Kind', type: 'select', allowOther: true, required: true,
        options: ['effect', 'route', 'combination', 'intro'],
        help: 'route sends the roll to another table; combination rolls this one again.' },
      // The same validator a class's bonuses go through. Dice and pools are
      // allowed, as on totems: a Morphus is generated once, and "1D4x10 to
      // S.D.C." is rolled then rather than re-read on every render.
      { name: 'bonuses', label: 'Bonuses', type: 'bonuses', flatOnly: false,
        help: 'JSON, a class bonuses block: {"attributes":{"PS":"1d6"},"combat":{"initiative":1},"pools":{"sdc":"1d4x10"}}. '
          + 'Natural weapons, senses and restrictions go in the description.' },
      // A roll as often as a number: 73 entries add "1d4", "1d6", "1d4+1" or
      // "1d4+2", and a few a fixed integer. Rolled once at creation, the way a
      // dice attribute bonus is rolled into `rolled_bonuses`.
      { name: 'horror_factor', label: 'Horror Factor +', type: 'dice',
        help: 'Added to the Morphus\'s Horror Factor: a whole number or dice, e.g. "2" or "1d4+1".' },
      { name: 'horror_factor_set', label: 'Horror Factor set to', type: 'int',
        help: 'Only for the entries that SET it rather than adding.' },
      { name: 'routes', label: 'Routes', type: 'json_list', of: { table: 'string', count: 'count' },
        help: 'JSON: [{"table":"Canine","count":1}]. A table the book never prints (Bear, Amphibian) '
          + 'is still written here - the generator rerolls it.' },
      { name: 'route_rule', label: 'Route rule', type: 'text',
        help: 'What the book says around the roll, e.g. "ignore and reroll 96-00".' },
      { name: 'sub_choices', label: 'Sub-choices', type: 'json_list', of: 'string',
        help: 'JSON list of strings, when the entry offers options inside itself.' },
      { name: 'description', label: 'Description', type: 'longtext' },
      { name: 'note', label: 'Note', type: 'longtext' },
      { name: 'system', label: 'System', type: 'select', options: ['rifts', 'palladium-fantasy', 'nightbane', 'heroes-unlimited', 'both'],
        help: 'Blank means unrestricted — offered to characters in any system.' },
      { name: 'source_book', label: 'Source book', type: 'text' },
    ],
  },

  // What an alchemist puts INTO a sword, as opposed to a sword. A catalog
  // declared here arrives with the editor, the write endpoints and the importer
  // already built from this config, which is the whole reason modelling
  // enchantments as their own table is affordable rather than a project.
  enchantments: {
    table: 'enchantments',
    label: 'Enchantments',
    displayField: 'name',
    uniqueField: 'slug',
    hasSource: false,
    fields: [
      { name: 'name', label: 'Name', type: 'text', required: true },
      { name: 'slug', label: 'Slug', type: 'text', required: true,
        help: 'What character_items.enchantments references. One per property the book names.' },
      { name: 'applies_to', label: 'Applies to', type: 'select',
        options: ['weapon', 'armor', 'charm'], required: true,
        help: 'charm covers rings, bracelets, charms and medallions - the book instils '
            + 'the effect IN one of those, three powers to an item.' },
      { name: 'cost', label: 'Cost', type: 'int',
        help: 'Gold, and the LOW end of a range - the same convention gear.cost follows.' },
      { name: 'cost_note', label: 'Cost note', type: 'text',
        help: 'The part a single integer cannot hold: "2,000 per 20 S.D.C., 200 max on heavy armour".' },
      { name: 'max_per_item', label: 'Max per item', type: 'int',
        help: 'The book caps armour at four features and weapons at three.' },
      { name: 'limits', label: 'Limits', type: 'text',
        help: 'What it can go on, when the book restricts it: "blunt weapons only, excluding ball & chain".' },
      { name: 'bonuses', label: 'Bonuses', type: 'bonuses',
        help: 'JSON, the same shape a class or skill uses: {"combat":{"initiative":3,"strike":2}}. '
          + 'A dice expression is allowed here - the Thunder Hammer is {"combat":{"damage":"2d6"}}' },
      { name: 'description', label: 'Description', type: 'longtext' },
      // `enchantments.system` is bare TEXT (db/schema.sql), so a third value
      // stores. `gear` and `vehicles` below are NOT widened: their `system`
      // columns carry a SQLite CHECK naming two values, and offering a third
      // here would put a value in the editor that the database refuses.
      // BOOK-INGEST-AUDIT F73.
      { name: 'system', label: 'System', type: 'select', options: ['rifts', 'palladium-fantasy', 'nightbane', 'heroes-unlimited', 'both'] },
      { name: 'source_book', label: 'Source book', type: 'text' },
    ],
  },

  gear: {
    table: 'gear',
    label: 'Gear',
    displayField: 'name',
    // Gear is the odd one out: unique on slug, and it has no `source` column.
    uniqueField: 'slug',
    hasSource: false,
    fields: [
      { name: 'name', label: 'Name', type: 'text', required: true },
      { name: 'slug', label: 'Slug', type: 'text', required: true,
        help: 'What equipment_starting[].item_id references. Changing it leaves the old slug redirecting here.' },
      { name: 'system', label: 'System', type: 'select',
        options: ['rifts', 'palladium-fantasy', 'nightbane', 'heroes-unlimited', 'both'] },
      { name: 'category', label: 'Category', type: 'select', allowOther: true,
        options: ['weapon', 'armor', 'vehicle', 'cybernetics', 'gear', 'magic'] },
      { name: 'weight_lbs', label: 'Weight (lbs)', type: 'real' },
      { name: 'cost', label: 'Cost', type: 'int',
        help: 'Credits (Rifts) or gold (Palladium Fantasy). A range goes in at its LOW end, '
            + 'the way a spell stores the minimum of a variable P.P.E. cost.' },
      { name: 'cost_note', label: 'Cost note', type: 'text',
        help: 'What the integer cannot hold: "20-100 cr.", "double for gold".' },
      // Stat block. Null wherever it does not apply — one table covers weapons,
      // armour and general equipment rather than branching on a type column.
      { name: 'damage', label: 'Damage', type: 'text', help: 'As written: "2D6 M.D. single shot, 6D6 M.D. burst"' },
      { name: 'is_mega_damage', label: 'Mega-damage', type: 'bool', blankAs: 0 },
      { name: 'range', label: 'Range', type: 'text' },
      { name: 'payload', label: 'Payload', type: 'text' },
      { name: 'rate_of_fire', label: 'Rate of fire', type: 'text' },
      { name: 'ar', label: 'A.R.', type: 'int' },
      { name: 'sdc', label: 'S.D.C.', type: 'int',
        help: 'What the OBJECT takes before it breaks - the other half of what Palladium armour is. '
            + 'Not the "1D6 S.D.C." a knife deals, which is Damage.' },
      { name: 'mdc', label: 'M.D.C.', type: 'int' },
      { name: 'description', label: 'Description', type: 'longtext' },
      { name: 'source_book', label: 'Source book', type: 'text' },
      { name: 'vehicle_slug', label: 'Is really a vessel', type: 'text',
        help: 'The vehicles slug this row is really a record of. Migration 053, '
            + 'BOOK-INGEST-AUDIT F41. Leave BLANK for actual gear, which is almost all '
            + 'of it. Setting it does not delete, hide or re-categorise this row: the '
            + 'row stays because class equipment lists cite it by slug, and the pointer '
            + 'only adds a way to reach the fuller vessel record.' },
    ],
  },

  // Vessels: power armour, robots, drones, borg models, combat vehicles and
  // ships. 127 rows that until now nothing could edit - migration 048 built the
  // three tables and PR #787 said outright that nothing in the app read them.
  //
  // THIS EDITS THE VESSEL'S OWN ROW AND NOTHING ELSE. `vehicle_locations` and
  // `vehicle_weapons` are one row per named part and per numbered weapon
  // system, which is the whole reason a vessel is three tables rather than one,
  // and this editor's shape is one table's columns in one form. Correcting a
  // location's M.D.C. or a weapon's damage is still a data script. Said here
  // because a form that silently edits two thirds of a thing is worse than one
  // that edits a third and says so.
  //
  // NO `MERGE_REFS` ENTRY, DELIBERATELY, and that is what keeps the duplicate
  // detector quiet: `resolveCatalog` requires both this config AND a
  // `MERGE_REFS` entry, so declaring a catalog here does NOT enlist it in
  // duplicate review. `enchantments` above has been in exactly that position
  // since it landed. The badge fetch in catalog.js fails silently by design -
  // "a badge that could not be computed is a missing hint" - so the panel
  // simply does not appear. Adding a `MERGE_REFS` entry would be the decision
  // to start proposing vessel merges, and nothing has asked for one; there is
  // also nothing yet for a merge to REPOINT, since no character can hold a
  // vessel and no class cites one.
  vehicles: {
    table: 'vehicles',
    label: 'Vessels',
    displayField: 'name',
    // Slug-keyed like gear and enchantments, and for the same reason: an id is
    // insertion order and means nothing in another database.
    uniqueField: 'slug',
    hasSource: false,
    fields: [
      { name: 'name', label: 'Name', type: 'text', required: true },
      { name: 'slug', label: 'Slug', type: 'text', required: true,
        help: 'The portable key, as gear.slug is. Nothing references it yet.' },
      { name: 'system', label: 'System', type: 'select',
        options: ['rifts', 'palladium-fantasy', 'nightbane', 'heroes-unlimited', 'both'] },
      { name: 'vehicle_class', label: 'Class', type: 'select', allowOther: true,
        options: ['power-armor', 'robot', 'drone', 'borg', 'vehicle', 'ship', 'other'],
        help: 'The column is free text so a book that invents a category is recorded rather '
            + 'than rejected, but it is normalised to these seven by convention - it is what '
            + 'the codex shows in its meta column. Put the phrase the book itself uses in the '
            + 'description instead of here. allowOther keeps an unrecognised stored value '
            + 'usable rather than silently rewriting it.' },
      { name: 'crew', label: 'Crew', type: 'text',
        help: 'Prose as often as a number - "one pilot", "two, plus six troops".' },
      { name: 'passengers', label: 'Passengers', type: 'text' },
      { name: 'speed_ground', label: 'Ground speed', type: 'text' },
      { name: 'speed_air', label: 'Air speed', type: 'text',
        help: 'Three regimes, each printed its own way - "Mach 1.2", "80 mph", '
            + '"1 light year per hour". Leave a regime blank where the book gives none.' },
      { name: 'speed_water', label: 'Water speed', type: 'text' },
      { name: 'dimensions', label: 'Dimensions', type: 'text' },
      { name: 'weight_tons', label: 'Weight', type: 'text' },
      { name: 'mdc_main_body', label: 'M.D.C. / S.D.C. (main body)', type: 'int',
        help: 'MAIN BODY ONLY. Every other part is a vehicle_locations row, which this '
            + 'form does not edit, so a reader wanting a total must sum them. WHICH UNIT '
            + 'this is comes from "Mega-damage" below, not from the column name: a Heroes '
            + 'Unlimited vehicle stores S.D.C. here, and one M.D.C. point absorbs a '
            + 'hundred S.D.C.' },
      { name: 'is_mega_damage', label: 'Mega-damage', type: 'int',
        help: '1 = the main body and this vehicle\'s location rows are M.D.C.; 0 = they are '
            + 'S.D.C. Defaults to 1, which is what every Rifts vessel is. Migration 062.' },
      { name: 'ar', label: 'A.R. (Armour Rating)', type: 'int',
        help: 'A to-hit threshold the rules read, the same number gear.ar holds for body '
            + 'armour. Leave it EMPTY for an M.D.C. vessel: those do not have one.' },
      { name: 'cost', label: 'Cost', type: 'int',
        help: 'Credits, and the LOW end of a range - the same convention gear.cost follows. '
            + 'LEAVE IT EMPTY when no book prices it: a vessel no market sells is a finished '
            + 'row, not an unfinished one.' },
      { name: 'cost_note', label: 'Cost note', type: 'text',
        help: 'What the integer cannot hold: a range, or "Not available on the open market".' },
      { name: 'description', label: 'Description', type: 'longtext' },
      { name: 'source_book', label: 'Source book', type: 'text' },
    ],
  },

  // Totem animals, Spirit West printed 96-105 (BOOK-INGEST-AUDIT.md F56). One
  // row per animal, shared by every class whose frontmatter says `totem:`, so
  // the forty entries live once rather than written into nine classes.
  //
  // NO `MERGE_REFS` ENTRY, for the reason vehicles gives above. And no redirect
  // either: `characters.totem` holds a slug, so RENAMING one orphans every
  // character holding it - the validator then says so as `totem_unknown`
  // rather than the totem silently granting nothing.
  totems: {
    table: 'totems',
    label: 'Totems',
    displayField: 'name',
    uniqueField: 'slug',
    hasSource: false,
    fields: [
      { name: 'name', label: 'Name', type: 'text', required: true },
      { name: 'slug', label: 'Slug', type: 'text', required: true,
        help: 'What characters.totem stores. Renaming it orphans every character holding the old one.' },
      { name: 'skills', label: 'Skills', type: 'skill_list',
        help: 'JSON, shaped like occ_skills: [{"name":"Swimming","bonus":10},{"name":"Hunting"}]. A bonus '
          + 'adds to the catalog base. Where the O.C.C. already has the skill, printed 96 gives +10% instead, '
          + 'and composition does that - do not write it here.' },
      { name: 'bonuses', label: 'Bonuses', type: 'bonuses', flatOnly: false,
        help: 'JSON, a class bonuses block. Dice and pools are allowed, since these apply at creation the '
          + 'way a class\'s do: {"attributes":{"PS":"1d4"},"pools":{"sdc":15},"saves":{"horror_factor":2}}' },
      { name: 'bonus_note', label: 'Bonus note', type: 'longtext',
        help: 'What the block cannot hold - "rarely surprised", "+2 to dodge underwater".' },
      { name: 'powers', label: 'Totem Warrior powers', type: 'longtext',
        help: 'Giant animal form only. Shown only by a class whose key says powers: true.' },
      { name: 'description', label: 'Traits', type: 'longtext' },
      { name: 'source_book', label: 'Source book', type: 'text' },
    ],
  },

  // The named people the books stat (migration 072). A G.M. copies one into a
  // campaign as a kind = 'npc' character, so the structured fields are the ones
  // a sheet reads and the rest is the book's prose. Attacks are stat_attacks
  // rows (migration 073), which this form does not edit - the vessels'
  // location rows are the precedent.
  //
  // NO `MERGE_REFS` ENTRY: nothing references a notable NPC by slug except its
  // own stat_attacks rows and the `notable:<slug>` class id of a campaign copy,
  // and a copy is deliberately a copy - renaming the catalog row must not
  // reach into a campaign.
  notableNpcs: {
    table: 'notable_npcs',
    label: 'Notable NPCs',
    displayField: 'name',
    uniqueField: 'slug',
    hasSource: false,
    fields: [
      { name: 'name', label: 'Name', type: 'text', required: true,
        help: 'What the book calls them - "Power Master", "Mayor Gwen Severson".' },
      { name: 'slug', label: 'Slug', type: 'text', required: true,
        help: 'The portable key. A campaign copy records it as class_id notable:<slug>.' },
      { name: 'real_name', label: 'Real name', type: 'text' },
      { name: 'title', label: 'Title', type: 'text' },
      { name: 'system', label: 'System', type: 'select',
        options: ['rifts', 'palladium-fantasy', 'nightbane', 'heroes-unlimited', 'both'] },
      { name: 'race', label: 'Race', type: 'text' },
      { name: 'occ', label: 'O.C.C. / occupation', type: 'text',
        help: 'As printed - "24th level Lord Magus". Not a class id: the book\'s numbers '
            + 'are this person\'s, and no class rules are applied over them.' },
      { name: 'level', label: 'Level', type: 'int' },
      { name: 'alignment', label: 'Alignment', type: 'text' },
      { name: 'age', label: 'Age', type: 'text' },
      { name: 'height', label: 'Height', type: 'text' },
      { name: 'weight', label: 'Weight', type: 'text' },
      { name: 'attributes', label: 'Attributes', type: 'kv',
        help: 'JSON with the sheet\'s eight keys: {"IQ":14,"ME":12,"MA":10,"PS":18,"PP":15,"PE":16,"PB":11,"Spd":22}' },
      { name: 'hp', label: 'Hit points', type: 'int' },
      { name: 'sdc', label: 'S.D.C.', type: 'int' },
      { name: 'mdc', label: 'M.D.C.', type: 'int' },
      { name: 'ppe', label: 'P.P.E.', type: 'int' },
      { name: 'isp', label: 'I.S.P.', type: 'int' },
      { name: 'ar', label: 'A.R.', type: 'int' },
      { name: 'horror_factor', label: 'Horror Factor', type: 'int' },
      { name: 'combat', label: 'Combat', type: 'kv',
        help: 'JSON with the sheet\'s combat keys, as the book totals them: '
            + '{"attacks":5,"initiative":2,"strike":3,"parry":4,"dodge":4,"roll":3,"pull":3}' },
      { name: 'bonuses_note', label: 'Other bonuses', type: 'longtext',
        help: 'What the combat block cannot hold - saves, "+2 to strike with a sword".' },
      { name: 'skills', label: 'Skills', type: 'json_list', of: { name: 'string', pct: 'count' },
        help: 'Percentile skills: [{"name":"Pilot Hovercraft","pct":88}]. W.P.s and '
            + 'Hand to Hand go in the note below.' },
      { name: 'skills_note', label: 'Other skills', type: 'longtext' },
      { name: 'natural_abilities', label: 'Natural abilities', type: 'longtext' },
      { name: 'magic', label: 'Magic', type: 'longtext' },
      { name: 'psionics', label: 'Psionics', type: 'longtext' },
      { name: 'super_powers', label: 'Super powers', type: 'longtext' },
      { name: 'cybernetics', label: 'Cybernetics', type: 'longtext' },
      { name: 'weapons_and_equipment', label: 'Weapons and equipment', type: 'longtext' },
      { name: 'money', label: 'Money', type: 'text' },
      { name: 'disposition', label: 'Disposition', type: 'longtext' },
      { name: 'allies', label: 'Allies', type: 'longtext' },
      { name: 'enemies', label: 'Enemies', type: 'longtext' },
      { name: 'description', label: 'Description', type: 'longtext',
        help: 'A short factual paraphrase citing the printed page - never the book\'s own sentences.' },
      { name: 'source_book', label: 'Source book', type: 'text' },
    ],
  },

  // The species the books stat (migration 074). Where a notable NPC holds the
  // book's NUMBERS, a creature holds its FORMULAS, and a campaign copy rolls
  // them (campaigns/:id/npcs/from-creature). Every formula field is `text`
  // rather than `dice`: the `dice` type reads class dice, and a creature's hit
  // points are as often "PE+20" as "3D6". js/creature-roll.js is the grammar,
  // and it REFUSES what it cannot read - so the help below states it.
  //
  // NO `MERGE_REFS` ENTRY, for notableNpcs' reason: a campaign copy's
  // `creature:<slug>` class id is a copy, not a reference to keep in step.
  creatures: {
    table: 'creatures',
    label: 'Creatures',
    displayField: 'name',
    uniqueField: 'slug',
    hasSource: false,
    fields: [
      { name: 'name', label: 'Name', type: 'text', required: true,
        help: 'The species as the book heads it - "Feathered Death", "Grimbor".' },
      { name: 'slug', label: 'Slug', type: 'text', required: true,
        help: 'The portable key. A campaign copy records it as class_id creature:<slug>.' },
      { name: 'category', label: 'Category', type: 'text',
        help: 'Free text: animal, monster, demon, faerie, dragon...' },
      { name: 'system', label: 'System', type: 'select',
        options: ['rifts', 'palladium-fantasy', 'nightbane', 'heroes-unlimited', 'both'] },
      { name: 'playable', label: 'Optional player race', type: 'bool', blankAs: 0,
        help: 'The book offers it as a player character. A catalog fact, not a class.' },
      { name: 'alignment', label: 'Alignment', type: 'text' },
      { name: 'attributes', label: 'Attributes', type: 'kv',
        help: 'JSON of the sheet\'s keys to FORMULAS: {"IQ":"2D6","PS":"4D6","PB":"N/A","Spd":"2D6x10"}. '
            + '"N/A" is an attribute the species does not have; leave out one the book does not print.' },
      { name: 'hp', label: 'Hit points', type: 'text', help: FORMULA_HELP },
      { name: 'sdc', label: 'S.D.C.', type: 'text', help: FORMULA_HELP },
      { name: 'mdc', label: 'M.D.C.', type: 'text', help: FORMULA_HELP },
      { name: 'ppe', label: 'P.P.E.', type: 'text', help: FORMULA_HELP },
      { name: 'isp', label: 'I.S.P.', type: 'text', help: FORMULA_HELP },
      { name: 'pools_note', label: 'Pools as printed', type: 'longtext',
        help: 'Any wording a formula above simplified - "gives most the equivalent of 1 or 2 M.D.C."' },
      { name: 'ar', label: 'Natural A.R.', type: 'int' },
      { name: 'horror_factor', label: 'Horror Factor', type: 'int' },
      { name: 'combat', label: 'Combat', type: 'kv',
        help: 'JSON of the sheet\'s combat keys, fixed numbers: {"attacks":3,"initiative":1,"strike":2,"dodge":4}' },
      { name: 'bonuses_note', label: 'Other bonuses', type: 'longtext' },
      { name: 'skills_note', label: 'Skills', type: 'longtext', help: 'Its R.C.C. skills, as the book lists them.' },
      { name: 'natural_abilities', label: 'Natural abilities', type: 'longtext' },
      { name: 'magic', label: 'Magic', type: 'longtext' },
      { name: 'psionics', label: 'Psionics', type: 'longtext' },
      { name: 'size', label: 'Size', type: 'text' },
      { name: 'weight', label: 'Weight', type: 'text' },
      { name: 'life_span', label: 'Life span', type: 'text' },
      { name: 'habitat', label: 'Habitat', type: 'longtext' },
      { name: 'allies', label: 'Allies', type: 'longtext' },
      { name: 'enemies', label: 'Enemies', type: 'longtext' },
      { name: 'occ_note', label: 'Optional O.C.C.s', type: 'longtext' },
      { name: 'description', label: 'Description', type: 'longtext',
        help: 'A short factual paraphrase citing the printed page - never the book\'s own sentences.' },
      { name: 'source_book', label: 'Source book', type: 'text' },
    ],
  },
};

export const CATALOG_KEYS = Object.keys(CATALOGS);

export function getCatalog(key) {
  return Object.prototype.hasOwnProperty.call(CATALOGS, key) ? CATALOGS[key] : null;
}

// Columns this catalog is allowed to read or write. Every SQL statement builds
// its column list from here, so a caller can never name a column itself.
export function fieldNames(cat) {
  return cat.fields.map((f) => f.name);
}

// Turn whatever arrived over the wire into the value that belongs in the column,
// or return an error string. Coercion lives here so the API and any future
// caller agree on what "empty" means.
export function coerceField(field, raw) {
  const blank = raw === undefined || raw === null || raw === '';

  if (field.required && blank) return { error: `${field.label} is required` };

  switch (field.type) {
    case 'int':
    case 'real': {
      if (blank) return { value: field.blankAs ?? null };
      const n = field.type === 'int' ? parseInt(raw, 10) : parseFloat(raw);
      if (!Number.isFinite(n)) return { error: `${field.label} must be a number` };
      return { value: n };
    }
    case 'bool': {
      // Accepts a real boolean from the model, a checkbox value, or the strings
      // a form or a book might produce. Stored as 0/1 because the column is
      // INTEGER NOT NULL.
      if (blank) return { value: field.blankAs ?? 0 };
      if (typeof raw === 'boolean') return { value: raw ? 1 : 0 };
      const s = String(raw).trim().toLowerCase();
      return { value: (s === 'true' || s === '1' || s === 'yes' || s === 'on') ? 1 : 0 };
    }
    case 'systems': {
      // NULL means "applies to EVERY system" — an empty array would mean
      // "applies to none", which is never what anyone intends.
      //
      // This read "both systems" until Nightbane made it three
      // (BOOK-INGEST-AUDIT F73) and Heroes Unlimited made it FOUR, and the
      // rule below changes meaning every time one is added: picking rifts and
      // palladium-fantasy used to be all of them and stored NULL, and now
      // stores the pair, because it has become a real restriction that
      // excludes the others. Existing NULL rows are NOT migrated and now read
      // as "all four" — deliberate, and inert today because the wizard's
      // system picker still offers two, so nothing resolves a skill against
      // `nightbane` or `heroes-unlimited` yet.
      if (!Array.isArray(raw) || raw.length === 0) return { value: null };
      const allowed = ['rifts', 'palladium-fantasy', 'nightbane', 'heroes-unlimited'];
      const picked = raw.filter((s) => allowed.includes(s));
      if (picked.length === 0 || picked.length === allowed.length) return { value: null };
      return { value: JSON.stringify(picked) };
    }
    case 'kv': {
      if (blank) return { value: '{}' };
      let obj = raw;
      if (typeof raw === 'string') {
        try { obj = JSON.parse(raw); } catch { return { error: `${field.label} is not valid JSON` }; }
      }
      if (typeof obj !== 'object' || Array.isArray(obj) || obj === null) {
        return { error: `${field.label} must be a set of key/value pairs` };
      }
      return { value: JSON.stringify(obj) };
    }
    case 'bonuses': {
      // NULL rather than '{}' when blank: most skills grant nothing, and an
      // empty object stored on every row would make "has bonuses" untestable
      // in SQL.
      if (blank) return { value: null };
      let obj = raw;
      if (typeof raw === 'string') {
        try { obj = JSON.parse(raw); } catch { return { error: `${field.label} is not valid JSON` }; }
      }
      if (obj === null) return { value: null };
      const errors = [];
      // Warnings are dropped deliberately - "PS: 0 will do nothing" is worth
      // saying about a class file someone is writing by hand, and is noise in a
      // catalog form where the field is optional anyway.
      // Flat-only by default because a SKILL's bonuses are re-read on every
      // render. A totem's apply at creation the way a class's do, dice and
      // pools included, so its field opts out (BOOK-INGEST-AUDIT.md F56).
      validateBonuses(obj, errors, [], { flatOnly: field.flatOnly !== false });
      if (errors.length) return { error: `${field.label}: ${errors[0]}` };
      return { value: JSON.stringify(obj) };
    }
    case 'skill_list': {
      // Validated by the parser's own validator, so a row cannot hold an entry
      // composition would misread. NULL when blank, as bonuses is.
      if (blank) return { value: null };
      let list = raw;
      if (typeof raw === 'string') {
        try { list = JSON.parse(raw); } catch { return { error: `${field.label} is not valid JSON` }; }
      }
      if (!Array.isArray(list)) return { error: `${field.label} must be a list` };
      const errors = [];
      validateSkillEntries(field.label, list, errors, []);
      if (errors.length) return { error: errors[0] };
      return { value: JSON.stringify(list) };
    }
    case 'json_list': {
      // NULL for blank AND for an empty list, so "has routes" stays a plain
      // IS NOT NULL in SQL - the reason bonuses stores NULL rather than '{}'.
      if (blank) return { value: null };
      let list = raw;
      if (typeof raw === 'string') {
        try { list = JSON.parse(raw); } catch { return { error: `${field.label} is not valid JSON` }; }
      }
      if (list === null) return { value: null };
      if (!Array.isArray(list)) return { error: `${field.label} must be a list` };
      if (!list.length) return { value: null };
      const bad = listEntryError(field.of, list);
      if (bad) return { error: `${field.label}: ${bad}` };
      return { value: JSON.stringify(list) };
    }
    case 'dice': {
      // TEXT either way, so an integer is stored in the same column shape as
      // a roll and a reader does not branch on SQLite's storage class.
      if (blank) return { value: null };
      if (typeof raw === 'number') {
        return Number.isInteger(raw) ? { value: String(raw) } : { error: `${field.label} must be a whole number or dice` };
      }
      const s = String(raw).trim();
      if (/^-?\d+$/.test(s)) return { value: String(parseInt(s, 10)) };
      if (isDiceBonus(s)) return { value: s };
      return { error: `${field.label} must be a whole number or a dice expression like "1d4+1"` };
    }
    case 'select': {
      if (blank) return { value: null };
      const v = String(raw);
      // allowOther exists so a value already in the database stays editable
      // even when it is not one of the options we know about.
      if (!field.allowOther && field.options && !field.options.includes(v)) {
        return { error: `${field.label} must be one of: ${field.options.join(', ')}` };
      }
      return { value: v };
    }
    default:
      return { value: blank ? (field.blankAs ?? null) : String(raw) };
  }
}

// Shape a stored row for the editor: JSON columns come back as real values so
// the form does not have to know they were ever text.
export function decodeRow(cat, row) {
  const out = { id: row.id };
  for (const f of cat.fields) {
    const v = row[f.name];
    if (f.type === 'systems') out[f.name] = v ? safeParse(v, []) : null;
    else if (f.type === 'kv') out[f.name] = v ? safeParse(v, {}) : {};
    else if (f.type === 'bool') out[f.name] = !!v;
    else out[f.name] = v;
  }
  if (cat.hasSource) out.source = row.source;
  return out;
}

// The first entry of a json_list that is not the shape `of` names, as a
// sentence, or null. Unknown keys are refused rather than kept: a stored key no
// reader knows is a value that silently does nothing.
function listEntryError(of, list) {
  for (const [i, e] of list.entries()) {
    const at = `entry ${i + 1}`;
    if (of === 'string') {
      if (typeof e !== 'string' || !e.trim()) return `${at} must be a non-empty string`;
      continue;
    }
    if (!e || typeof e !== 'object' || Array.isArray(e)) return `${at} must be an object`;
    for (const k of Object.keys(e)) {
      if (!Object.prototype.hasOwnProperty.call(of, k)) return `${at} has an unknown key "${k}"`;
    }
    for (const [k, kind] of Object.entries(of)) {
      const v = e[k];
      if (kind === 'string' && (typeof v !== 'string' || !v.trim())) return `${at} needs "${k}" as a non-empty string`;
      if (kind === 'count' && !(Number.isInteger(v) && v >= 1)) return `${at} needs "${k}" as a whole number of at least 1`;
    }
  }
  return null;
}

function safeParse(text, fallback) {
  try { return JSON.parse(text); } catch { return fallback; }
}
