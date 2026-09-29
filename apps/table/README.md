# The Table

One live room per game session, for Palladium/Rifts and Marvel. The GM opens
it from the campaign page and reads out a four-letter code; players join on
their phones, a laptop on the TV joins as the Display, and every roll lands on
exactly the screens allowed to see it. On Discord nights the GM screen-shares
the Display.

Design: [The Table — live game room design](https://claude.ai/code/artifact/127a98a9-7907-41a6-be73-a7f1de4a1787).
Phase 1 is the room and the roll feed; phase 2 is showing pictures; phase 3
is initiative.

## Three screens, one page

| | Display (the TV) | A player's phone | The GM |
|---|---|---|---|
| sees | public rolls, in large type; the picture on the table, fitted to the screen on black; the initiative strip, with the name that is up large | public rolls, and their own To-GM rolls; the picture, under the feed, tap for full screen and pinch-zoom; the initiative order, "You're up" (and a vibration) and "On deck" | every roll, GM-only ones included; the picture; the whole order, hidden NPCs by name |
| does | nothing | rolls from the dice box, Everyone or To GM; rolls their own initiative (Palladium) | rolls Everyone or GM only; runs initiative; closes the table. Shows and clears pictures from Present mode |

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

The GM can also show one **from the table page**, without leaving it: its
**Show a picture** panel lists every Setting page's pictures as thumbnails,
and on Palladium the campaign's city maps. A click shows it and **Clear the
table** takes it down, through the same `table/show` and `table/clear` routes
Present mode calls. The lists come from the GM-only routes the Setting pages
already use, and only the GM's page draws the panel.

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

## Initiative

The room keeps one order and one current turn; each game supplies how the
order is rolled and how a round runs out. **The GM always drives**: a turn
moves only on Next, a round only on New melee or Roll the round.

| | Palladium / Rifts | Marvel |
|---|---|---|
| who rolls | each player taps **Roll initiative** on their phone: d20 plus the sheet's bonus. The GM rolls for NPCs | the GM presses **Roll the round** |
| the rule | highest total first; a tie goes to the higher bonus, then only the tied re-roll (`workers/table-room/src/palladium.js`) | house rule R25, the Marvel app's own `apps/marvel-heroes/js/initiative.js`, called by the room |
| a round | one melee: each combatant acts once per pass, spending one attack; passes repeat until every # of Attacks is spent, and anyone out of attacks is skipped. **New melee** keeps the order; **New melee, roll again** clears it | one pass through the order; past the last, the round ends and the Talent ticks clear |

**A player's numbers come from D1, never the page.** When a player joins, the
game's adapter reads their character: Palladium's initiative bonus and attacks
per melee derived as the sheet derives them
(`functions/api/character-creator/_lib/combat-numbers.js`), Marvel's Agility
number and Talents from the hero's sheet. The room keeps them on the seat, and
a phone's Roll initiative carries nothing. The GM adds from the campaign's
roster (`table/roster`: its characters and statted NPCs, with their numbers)
or by name, and is believed about the GM's own table.

**Hidden NPCs.** An NPC is visible to everyone by default. The GM can hide
one, and then every other screen gets it as `???` in its place and nothing
else: no name, no roll, no numbers (`initView()` in
`workers/table-room/src/initiative.js`, the one way the order leaves the
room). Its initiative roll goes into the feed as GM only.

**"You're up"** goes only to the phones seated as that character, and "On
deck" only to the next one's. On reconnect the page reads the same from the
order in `state`.

**Mid-fight** the GM drags a row (or uses its arrows), takes anyone out
(removing whoever is up passes the turn on without spending their attack), or
adds a latecomer, who is slotted in by their roll.

On Marvel, GM Tools' own initiative panel still works while no table is open,
in that browser as before; while one is open it points here, and its room view
opens the table's TV view.

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
| `workers/table-room/src/initiative.js` | the order, the turn, and what each screen may see of it |
| `workers/table-room/src/palladium.js` | Palladium's roll, tie-break and melee |
| `workers/table-room/test/room.mjs` | the suite: the room, the routes against `node:sqlite`, and these clients |

Locally: start `table-room` then `nates-apps+table` from `.claude/launch.json`
(port 8792). On localhost the Access email header is yours to set, which is how
a second or third person is tested from one machine.
