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
| 1 | engine, Palladium Fantasy tables, settings, text output, lock and reroll, JSON export | done |
| 2 | SVG district map with pins, race quarters drawn | done |
| 3 | D1 `cities` table, linked to a campaign, G.M.-only by `campaigns.gm_email`, print styles | done |
| 4 | roll stats for an NPC (4a, done), shop inventories (4b, done), a player view, an AI "Flesh out" | in progress |
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

## The map

**`js/city-map.js`** lays out a district map from the city, seeded like the
rest. It is a district map and not a street map (out of scope by the plan):
the city's outline is cut into one region per district by the perpendicular
bisectors between their sites, so every point belongs to exactly one district.
Race quarters are hatched; the wall and its gates appear only when the city has
walls; main roads run from the central square out through the gates; about half
of cities get a river. Every place and shop is a numbered pin inside its own
district, clear of the label and of the other pins, and each pin links to its
entry - the numbered key under the map is the large tap target on a phone.

The map is **computed when the city changes and kept with it**, not redrawn on
load, so a later change to the layout never moves a saved city's districts.
`?seed=N` opens on that city with the settings on screen (built-in names only),
which is also how the print check renders a page without clicking. The map
prints in the page's strokes, sized to share a page with the overview.

## Keeping a city

**Keep it in a campaign** saves the city into one of the G.M.'s own campaigns of
the same game (`cities`, migration 080) - the whole city as generated, map and
AI name pool included, never just its seed, so a later change to the tables or
the layout cannot change it. There is no owner column: a city's G.M. is its
campaign's `gm_email`, and `requireCampaign` is the check.

**Everything is the G.M.'s until shown.** Once kept, the city gets a
**Show the map to players** switch, a **👁 / 🙈** switch beside each pin in the
map's key, and a **what the players read** line under each district, place and
shop. Those three are all a player view will ever be built from - a G.M.'s
secret sits in fields it never reads - and the reveal and players' lines are
saved as they are flipped, not held for *Save changes*. A reroll keeps them.
To anyone but the G.M., a whole city is a 404 whether or not its map is shown,
and the campaign's list shows them only shown cities, as summaries. The
players' own view (through present mode) is Phase 4.

Printing leaves the keeping controls off the page and prints only the players'
lines that were written.

## Shop inventories

**📦 Stock it** (or **Stock every shop from the Codex**) puts 6-10 real gear
rows from the Codex on a shop's shelf, chosen by that kind of shop's rule
(`SHOP_STOCK` in the tables: gear categories, and a pattern an item's name must
match - a smithy's weapons, chain, locks and traps; a scribe's books, ink and
parchment). Each row is priced at the **book price times the city's wealth**
(a Poor city 0.8, a Rich one 1.5), with the book price shown beside it. The rows
are copied into the city - slug, name, book price, this city's price - so a kept
city keeps its stock when the Codex changes. **🎲 Restock** draws that shop
again and no other. A rule the Codex can only partly fill stocks what exists
and says so; nothing is invented to fill a shelf. Regression checks that every
kind of shop can be stocked with six or more real rows.

## Rolling stats for an NPC

On a kept city, each named NPC has **🎲 Roll stats**. It sends them to the
ordinary NPC roller (`campaigns/:id/npcs/generate`, `js/npc-generate.js`) in
the city's campaign as their race's R.C.C. with the job their role maps to
(`ROLE_OCC` in the tables: commoners are Vagabonds/Peasants, a guard is a
Soldier, a shop owner a Merchant), under their own name. The sheet it makes is a
statted NPC in that campaign like any other, and the entry keeps a **📜 open
sheet** link to it; rerolling the entry makes a new person and drops the link.

**The roller refuses rather than guesses, and the page shows the refusal as it
comes** - a race whose page bars that job, or a class the roller cannot build.
Measured 2026-09-23 on the local server: most Palladium Fantasy race and job
pairings are refused today on a language pick (only Soldier and Noble roll),
a gap in the roller itself and filed as its own piece of work; nothing here
pads around it.

The page also keeps the city on screen in this browser's storage, so a reload
does not lose it - a convenience; the record is the saved row - and **Export
JSON** hands it over as a file.

The smoke suite's *City Creator engine* section
(`apps/character-creator/test/checks/city-creator.mjs`) proves the engine's
promises against the module itself.
