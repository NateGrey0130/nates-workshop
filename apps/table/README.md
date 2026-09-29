# The Table

One live room per game session, for Palladium/Rifts and Marvel. The GM opens
it from the campaign page and reads out a four-letter code; players join on
their phones, a laptop on the TV joins as the Display, and every roll lands on
exactly the screens allowed to see it. On Discord nights the GM screen-shares
the Display.

Design: [The Table — live game room design](https://claude.ai/code/artifact/127a98a9-7907-41a6-be73-a7f1de4a1787).
Phase 1 is the room and the roll feed; phase 2 is showing pictures. Initiative
(phase 3) is not built yet.

## Three screens, one page

| | Display (the TV) | A player's phone | The GM |
|---|---|---|---|
| sees | public rolls, in large type; the picture on the table, fitted to the screen on black | public rolls, and their own To-GM rolls; the picture, under the feed, tap for full screen and pinch-zoom | every roll, GM-only ones included; the picture |
| does | nothing | rolls from the dice box, Everyone or To GM | rolls Everyone or GM only; closes the table. Shows and clears pictures from Present mode |

**The page never decides what it is shown.** It asks for a role; the game's
join route decides from D1 whether the person may take it, and the room sends
each socket only what `canSee()` in `workers/table-room/src/visibility.js`
allows. A GM-only roll is never sent to a player's phone or the TV, so there is
nothing on a device to dig out of the page. `?as=display` in the URL makes a TV
bookmark rejoin as the Display without asking.

## Where a roll comes from

- **The dice box** here: `d20`, `2d6+3`, `d100`, any dice expression, and on a
  Marvel table a FEAT on the Universal Table, rolled on the server with the
  Marvel app's own `js/feat.js`.
- **The character sheet** (Palladium): while a character is seated here, every
  roll its sheet logs is also sent to the table, as the same note `rollNote()`
  wrote. The sheet keeps saving to the session log itself; the table saves
  nothing there. A roll sent To the GM is marked private in the log too, so
  only its owner and the G.M. read it back.

## Pictures on the table

The GM's Present mode (`shared/js/campaign/present.js`, both games) gains
**Show to table** and **Clear the table** while the campaign has a table open.
Paging through pictures there still previews them for the GM alone; the table
sees nothing new until Show is pressed again. The pictures are the ones Present
mode already shows: a setting page's pictures, and on the Palladium side a City
Creator city's map, drawn for the table from the players' view only
(`functions/api/character-creator/_lib/city-svg.js`).

**Show is not Reveal.** Showing is for the moment: it writes nothing to the
campaign, is not saved with the feed, and ends at Clear or when the table
closes. Reveal is still the separate button that puts a picture in the
players' Handouts for good.

**Who can fetch it.** Screens load the picture from the game's
`table/image?code=&kind=&id=` route, which asks the room first. It answers
only while that picture is the one on the table and the caller is connected
there as the GM, the Display or a seated player (`mayFetch()` in
`workers/table-room/src/showing.js`). Anything else is a 404: before Show,
after Clear, another picture, someone not at the table. It is served
`no-store`, so a browser's copy does not outlive Clear. The campaign's own
image routes are untouched: an unrevealed picture is still not found there.

## Where it is saved

Closing the table writes every roll to the campaign (`table_sessions`, or
`msh_table_sessions` for Marvel) and the campaign page shows the saved
sessions, each filtered for the reader by the same rule the room used live. A
table nobody has been connected to for twelve hours closes itself but keeps its
rolls, and the campaign page saves them on the GM's next visit.

## The pieces

| where | what |
|---|---|
| `apps/table/` | this page |
| `shared/js/campaign/table.js` | the panel on both games' campaign pages: open, the code, close, saved sessions |
| `workers/table-room/` | the room: a Durable Object per code. **A merge does not deploy it**: `node scripts/deploy-table-room.mjs` |
| `functions/api/_lib/table-room.js` | the route handlers both games share |
| `functions/api/character-creator/table/`, `functions/api/marvel-heroes/table/` | each game's routes, reaching only its own D1 |
| `functions/api/table/lookup.js` | which game a code belongs to |
| `workers/table-room/src/showing.js` | who may look at, and fetch, the picture on the table |
| `workers/table-room/test/room.mjs` | the suite: the room, the routes against `node:sqlite`, and these clients |

Locally: start `table-room` then `nates-apps+table` from `.claude/launch.json`
(port 8792). On localhost the Access email header is yours to set, which is how
a second or third person is tested from one machine.
