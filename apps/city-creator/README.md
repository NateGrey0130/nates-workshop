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
| 4 | roll stats for an NPC (4a), shop inventories (4b), a player view (4c), an AI "Flesh out" (4d) | done |
| 5 | the Rifts table set: tech level, Coalition presence, ley lines, M.D.C. walls | done |

## How it works

- **`js/city-engine.js`** is a pure module with a seeded generator: the same
  seed and settings always give the same city. Each section is seeded on its
  own, so more NPCs changes the NPCs and nothing else, and a one-entry reroll
  reseeds that entry alone.
- **`js/city-tables-pf.js`** is every line the Palladium Fantasy city is built
  from - 40 or more entries per table, all written for this file. Nothing is
  copied from a sourcebook or an OCR cache. The setting is a switch, and
  **`js/city-tables-rifts.js`** is the second file in the same shape - see
  *Rifts* below.
- **Names** come from `shared/js/namegen.js` (a theme per race - Wolfen names
  for Wolfen - and the places theme for taverns and districts), run in the
  browser with the city's seeded random. **A shop is named by its kind**: each
  kind carries its own words in the tables (`names`: a smithy's Forge and
  Anvil, a body-chop-shop's Cybernetics and Bionics), set with a surname or one
  of the setting's `SHOP_ADJECTIVES` - "Greenholt's Forge", "The Northern Body
  Works". Taverns and bars keep the places theme's names, which already read
  as taverns. **With a naming theme**, one call to
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
and the campaign's list shows them only shown cities, as summaries.

## What the players see

**▶ Present what the players see** opens present mode on the city
(`/apps/gm-tools/present.html?city_id=`). It reads `cities/:id/view`, which
the server builds from the saved city and nothing else: the map's shapes and
district names, the pins the G.M. revealed (renumbered 1 to n, so a hidden pin
leaves no gap), and each entry's players' line. No NPC, rumour, hook, stock,
secret or G.M. description is in it, so the page cannot leak what it was never
sent. It is a 404 to a player until the map is shown, and the G.M. can open it
beforehand as a preview. Players reach it from the campaign's **Handouts**
tab, which lists every shown city.

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
Nothing here pads around it.

A measurement on 2026-09-23 had most Palladium Fantasy race and job pairings
refused on a language pick. **That was the local dev database, not the
roller.** It had run the first version of
`zzzzzzzzzzzzzzzz-tag-skill-systems.sql`, which tagged the named languages
Rifts and Heroes Unlimited, and never the correction that leaves them for
every game. Production and a database built from the repo leave them
untagged, and there every race rolls with every occupation it allows. The
regression sweep now rolls every such pairing and fails if a language pick
runs dry.

## Flesh out

Each district, place, shop and named NPC has **✨ Flesh out**. One press is one
call to `/api/claude` for that entry alone: the prompt carries the entry as it
stands (an NPC's look, want and secret, a shop's specialty and owner) and a
line about the city, and asks for two or three short original paragraphs for
the G.M. The answer is tidied to plain prose and saved **into the entry** as
`flesh` - on a kept city at once, like a rolled sheet. Pressed again, it writes
a new one over the old. An empty answer is an error the page shows and nothing
is saved.

It is part of the entry: a lock keeps it through a reroll, and rerolling the
entry makes a new one without it. It prints with the entry, and it never
reaches the players - the players' view is built from an allowlist that does
not read it, and the regression suite's leak check carries a fleshed-out
revealed place to prove it.

Quirks and rumours have no button: each is one line, and a paragraph about a
rumour would decide what the G.M. has not.

## Rifts

Choose **Rifts** under *Setting* and the city is built from
`js/city-tables-rifts.js` instead: 40 or more lines per table, all written
fresh for that file, and none carried over from the Palladium Fantasy one (a
smoke check compares them). A Rifts overview adds three lines of its own - a
**tech level**, how much the **Coalition** is present, and the **ley lines** -
and every wall is an M.D.C. wall. A Palladium Fantasy city draws none of those
and is built exactly as before.

- **Races** are the setting's published R.C.C.s, plus a **Human** row: Rifts
  humans take an O.C.C. and have no R.C.C. of their own. Switching the setting
  resets a race list the new setting has no classes for.
- **Names** come from the Rifts themes (`rifts-frontier` by default,
  `rifts-places` for bars and districts, and each shop kind's own words for shops). Every Rifts people theme now has
  200 or more name parts; the Dog Boy and Atlantean themes were filled out to
  get there.
- **Shops** are the Rifts kinds - bars, gun shops, body-chop-shops,
  Techno-Wizard shops, vehicle lots and more - and each stocks 6 or more real
  Rifts rows from the Codex, priced in credits.
- **Roll stats** sends a human as their job's O.C.C. alone. Another race goes
  as its R.C.C. alone, or with the job's O.C.C. when the roller says that race
  takes one (a Noro, a Psi-Pony) - the page reads that from the roller's own
  rule when the race is chosen. Every mapped O.C.C. rolls on a database built
  from the repo, which matches production here. The **Rogue Scholar** was
  refused on the local dev database only: its "three Literacy: Other" pick
  draws from the literacies the catalog names, and that database was missing
  two of the four (Gypsy and Russian), whose scripts it had never run.

The page also keeps the city on screen in this browser's storage, so a reload
does not lose it - a convenience; the record is the saved row - and **Export
JSON** hands it over as a file.

The smoke suite's *City Creator engine* section
(`apps/character-creator/test/checks/city-creator.mjs`) proves the engine's
promises against the module itself.
