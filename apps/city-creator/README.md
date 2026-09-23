# City Creator

A G.M.'s tool that makes a whole city on the fly: an overview, districts with a
d6 encounter table each, places of interest, shops and taverns with their
owners, named NPCs, city quirks, and a d10 rumour table marked true or false.
Pick the settings, press Generate, then **lock** the parts you like and
**reroll** the rest, down to a single entry.

It is the sixth app of the RPG suite (the shared header, the Board & Tissue
sheets). Built one phase per PR; the plan's phases are:

| phase | what | state |
|---|---|---|
| 1 | engine, Palladium Fantasy tables, settings, text output, lock and reroll, JSON export | this PR |
| 2 | SVG district map with pins, race quarters drawn | to come |
| 3 | D1 `cities` table, linked to a campaign, G.M.-only by `campaigns.gm_email`, print styles | to come |
| 4 | roll stats for an NPC, shop inventories, a player view, an AI "Flesh out" | to come |
| 5 | the Rifts table set | to come |

## How it works

- **`js/city-engine.js`** is a pure module with a seeded generator: the same
  seed and settings always give the same city. Each section is seeded on its
  own, so more NPCs changes the NPCs and nothing else, and a one-entry reroll
  reseeds that entry alone.
- **`js/city-tables-pf.js`** is every line the Palladium Fantasy city is built
  from - 40 or more entries per table, all written for this file. Nothing is
  copied from a sourcebook or an OCR cache. The setting is a switch: Rifts will
  be a second file in the same shape.
- **Names** come from `shared/js/namegen.js` (a theme per race - Wolfen names
  for Wolfen - and the places theme for shops and districts), run in the
  browser with the city's seeded random. **With a naming theme**, one call to
  `/api/claude` returns a name pool that is saved with the city; locks and
  rerolls draw from that pool and never call again.
- **Population** sets the number of districts, shops and places and whether
  there are walls. **The named-NPC count** is the G.M.'s alone, and shop owners
  are among those NPCs - with fewer NPCs than shops, one person owns two.
- **The racial breakdown** is chosen from the setting's published R.C.C.s (the
  classes request leaves retired ones out by `deleted_at`) and must total 100%.
  A race at 20% or more gets its own quarter, and some quirks and shops only
  appear when their race is in the city. *At least one NPC of every listed race*
  is on by default.
- **Refuse, never pad.** A table line whose `{slot}` the city cannot fill is
  skipped, and a name source that runs out leaves the entry unnamed and says so,
  rather than repeating a name.

Nothing is saved on the server yet (Phase 3). The page keeps the last city in
this browser's storage so a reload does not lose it, and **Export JSON** hands
it over as a file.

The smoke suite's *City Creator engine* section
(`apps/character-creator/test/checks/city-creator.mjs`) proves the engine's
promises against the module itself.
