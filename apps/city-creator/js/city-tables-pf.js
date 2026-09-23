// The City Creator's Palladium Fantasy tables - every line a generated city is
// built from, apart from its names (shared/js/namegen.js, or the AI name pool).
//
// ALL OF IT WAS WRITTEN FOR THIS FILE. Nothing is copied from a sourcebook or
// an OCR cache, and no book text is committed here. The setting is a switch:
// a Rifts table set (Phase 5) is a second file in this shape, and the engine
// reads whichever one the city's `system` names.
//
// SIZE IS THE POINT. The plan's bar is 40 or more entries per table, because
// too few is what makes every city feel the same. A smoke check reads that bar
// back out of this file rather than trusting the comment.
//
// Templates may carry {slots} the engine fills from the city being built:
//   {npc} a named NPC   {district} a district   {place} a place of interest
//   {shop} a shop       {faction} a faction      {race} a race in the city
//   {city} the city's own name
// A line with a slot the city cannot fill (a {faction} in a hamlet with none)
// is skipped, never filled with a stand-in.

const lines = (s) => s.split('\n').map((x) => x.trim()).filter(Boolean);

export const SIZES = [
  // max: the population a size runs to. Counts are [min, max] before quarters.
  { id: 'hamlet', label: 'Hamlet', max: 99, suggest: 60,
    districts: [1, 1], shops: [1, 2], places: [1, 2], factions: [0, 1], walls: 0 },
  { id: 'village', label: 'Village', max: 999, suggest: 450,
    districts: [2, 3], shops: [3, 5], places: [2, 3], factions: [1, 2], walls: 0.25 },
  { id: 'town', label: 'Town', max: 4999, suggest: 2500,
    districts: [3, 4], shops: [6, 9], places: [4, 6], factions: [2, 2], walls: 0.7 },
  { id: 'city', label: 'City', max: 24999, suggest: 12000,
    districts: [5, 7], shops: [10, 14], places: [6, 9], factions: [2, 3], walls: 1 },
  { id: 'metropolis', label: 'Metropolis', max: Infinity, suggest: 60000,
    districts: [8, 10], shops: [15, 20], places: [9, 12], factions: [3, 3], walls: 1 },
];

export const WEALTH = [
  { id: 'destitute', label: 'Destitute', price: 0.6, line: 'Coin is scarce; most trade is barter and favours.' },
  { id: 'poor', label: 'Poor', price: 0.8, line: 'People get by, and a stranger\'s silver is noticed.' },
  { id: 'modest', label: 'Modest', price: 1, line: 'Enough to eat, enough to trade, not enough to waste.' },
  { id: 'prosperous', label: 'Prosperous', price: 1.25, line: 'Full markets, new roofs, and prices to match.' },
  { id: 'rich', label: 'Rich', price: 1.5, line: 'Old money, new money, and guards to watch both.' },
];

export const PRICE_LEVELS = ['bargain', 'fair', 'fair', 'steep', 'extortionate'];

export const WALLS = lines(`
  a timber palisade with two gates
  an earthen rampart topped with stakes
  a stone curtain wall with square towers
  a double ring of walls, the inner one older
  a crumbling old wall the town has long outgrown
  a stout wall with a water-gate onto the river
  a wall of dressed grey stone and three gatehouses
  a patched wall where every repair is a different stone
`);

export const GOVERNMENTS = lines(`
  a hereditary baron who rarely leaves the keep
  a council of guild masters that meets on market day
  an elected mayor and a quarrelsome aldermen's bench
  a temple that collects the taxes and keeps the peace
  a military governor appointed from far away
  a merchant prince whose family owns half the docks
  the eldest of three rival families, for now
  a sheriff who answers to a distant count
  a lady regent ruling for a child heir
  a circle of elders who decide by long argument
  a wizard who took the town's charter as payment for a service
  a captain of mercenaries who never left after the war
  an assembly of every freeholder, loud and slow
  a bishop and a baron who share power and loathe each other
  a guild of money-changers in all but name
  an old knight too honest for the job
  a lord who sold the governing rights to a tax farmer
  a woman who rules because nobody else would
  the harbourmaster, since the harbour is the town
  a young noble newly granted the town as a reward
  a council of nine chosen by lot each spring
  the head of the miners' fraternity
  a mayor who is plainly in the thieves' guild's pocket
  a sorcerer-lord seen only at the solstice feasts
  an abbey whose abbot is lord of the land by old charter
  a warlord's appointed reeve, feared and efficient
  a pair of twin brothers who govern in alternate years
  the family that owns the only bridge
  a retired adventurer who bought the title
  a steward acting for a lord missing these seven years
  a guildhall where votes are bought openly
  the clan chief of the oldest family in the valley
  a governor from the Empire, unpopular and well guarded
  a people's council formed after the last lord was hanged
  a lord who is secretly deep in debt to the moneylenders
  a judge whose word is law and whose word is for sale
  an order of knights who hold the town as a commandery
  a merchants' league that elects a new speaker each year
  the old queen's cousin, exiled here in comfort
  nobody at all - the last lord died and nothing replaced him
`);

export const TRADES = lines(`
  wool and woven cloth
  river fish, salted and smoked
  timber floated down from the hills
  iron from the nearby mines
  wine from the terraced slopes
  horses, bred and broken
  salt from the pans on the flats
  furs traded from the northern trappers
  pottery from the red clay beds
  a great fair that draws buyers from every direction
  ship-building and ship repair
  grain, milled and shipped
  stone from the quarries above the town
  silver, and the smiths who work it
  tolls from the only pass for leagues
  beer brewed from the valley's hops
  leather and the tanneries that stink of it
  pilgrims visiting the old shrine
  dyes made from river moss and madder
  honey, mead and candle wax
  glass blown from fine white sand
  herbs and the remedies made from them
  paper and ink for a hundred scribes
  rope and sailcloth
  the caravan trade passing east and west
  cheese from the upland dairies
  copper, mined and hammered
  weapons forged for mercenary companies
  spices landed from far ports
  cattle driven to market each autumn
  books copied in the scriptoria
  alchemical reagents dug from the marshes
  gems from the cliff mines
  a famous hot spring and the travellers it brings
  olives and the oil pressed from them
  flax and fine linen
  whale oil and bone
  a college of magic and its many needs
  mercenaries, hired out by the company
  smuggling, if anyone is honest about it
`);

export const FACTIONS = lines(`
  The Merchants' Compact, who want the tolls lowered and the roads safer
  The Old Families, who want things as they were before the new money came
  The Temple of the Light, who want a bigger cathedral and more faithful
  The Night Market, who want the watch to look the other way
  The Watch Captain's men, who want better pay and fewer bosses
  The Tanners' and Dyers' Guild, who want the council to stop moving them downwind
  The Freeholders, who want their grazing rights back
  The Scholars of the Library, who want a book the baron will not lend
  The Rivermen, who want a share of the bridge toll
  The Young Nobles, who want a war to make their names in
  The Sisterhood of Mercy, who want the plague ward reopened
  The Iron Company, mercenaries who want a permanent contract
  The Brotherhood of the Coin, moneylenders who want their loans repaid
  The Circle of Wizards, who want an old tower returned to them
  The Harbour Gangs, who want every cargo to pass through their hands
  The Pilgrims' Hostel, who want the shrine's road kept open
  The Hill Clans, who want the town to stay out of the high valleys
  The Masons' Lodge, who want the new wall built by them and nobody else
  The Beggars' King, who wants to be recognised as a guild
  The Order of the Shield, knights who want the old fort garrisoned
  The Reformers, who want the council chosen by vote
  The Heralds' College, who want every family's claims recorded properly
  The Farmers' Union, who want a fair price for grain at market
  The Silent Hand, assassins who want only to be left in peace
  The Druids of the Grove, who want the old forest left uncut
  The Players' Company, who want a theatre and a licence
  The Foreign Traders, who want to own property in the town
  The Veterans, who want the pensions they were promised
  The Apothecaries, who want the hedge-witches banned from selling
  The Cult of the Dark Star, who want a door opened that should stay shut
  The Salt Brokers, who want the salt tax raised on everyone else
  The Ferrymen, who want the new bridge never finished
  The Widows of the Mine, who want the collapse investigated
  The Horse Lords, who want the market moved to their land
  The Glassmakers, who want the secret of their furnaces kept
  The Bell-Ringers, who want the cathedral bell recast
  The Scribes' Guild, who want every contract written by them
  The Smugglers of the Low Quay, who want the customs house burned
  The Keepers of the Shrine, who want a relic returned
  The Gardeners' Society, who want the common kept common
`);

// A district's kind and the mood that goes with it. `mood` lines are
// templates; the engine picks one per district.
export const DISTRICT_KINDS = lines(`
  Market
  Docks
  Temple Hill
  Old Town
  Craftsmen's Row
  Noble Quarter
  Tanneries
  Slums
  Garrison
  University
  Warehouses
  Gardens
  Mills
  Foreign Quarter
  Fairground
  Bridges
  Guild Hall District
  Stockyards
  Cemetery Hill
  Lantern Lanes
  Bathhouses
  Stables
  Quarry Edge
  Fishers' Strand
  Castle Mount
  Burnt Quarter
  Artists' Lanes
  Pilgrims' Road
  Money-changers' Row
  Riverside
  Shambles
  Tenements
  Theatre Lanes
  Customs Quay
  Almshouses
  Gatehouse Ward
  Orchards
  Wizards' Rise
  Smithies
  Old Walls
`);

export const MOODS = lines(`
  Loud from dawn and quiet only after the last bell.
  Everyone here knows everyone, and watches a stranger go by.
  Washing hangs between the houses and children run underfoot.
  The streets are swept, the doors are painted, and the watch is polite.
  It smells of smoke, wet stone and something cooking.
  Half the shutters are closed and the other half are watching.
  Prosperous once, and still pretending.
  Busy with carts, shouting and the rattle of barrels.
  Hushed, as if the whole district were listening for something.
  Music spills out of three different doors at once.
  Rain collects in the ruts and nobody has fixed them in years.
  Pale stone, tall windows and a great deal of money.
  Crowded, cheerful and not safe after dark.
  The old families live here and let you know it.
  Everything is for sale, and the price is always negotiable.
  A place of workshops, sawdust and hammering.
  Quiet gardens behind high walls.
  Beggars on the steps, bells overhead, incense in the air.
  Soldiers drill in the square every morning.
  The river is close enough to hear, and smell.
  A maze of alleys that locals navigate by memory.
  Lanterns burn late and business goes on after dark.
  New buildings rise over the ashes of the old.
  Everyone seems to be waiting for something to happen.
  Neat, orderly and suspicious of anything that is not.
  Wind-swept, open and poor.
  Scholars argue on the corners over cups of cheap wine.
  Strangers from far away, their foods, their gods and their songs.
  Cattle, dust and the shouts of drovers.
  The graves outnumber the living, and the living keep to themselves.
  The oldest streets, crooked and narrow and full of stories.
  Wealth hides behind plain fronts.
  A street party seems to be going on at all hours.
  Fear lingers from something that happened last winter.
  Smells of dye and leather follow you for a day.
  Tall, narrow houses leaning on each other like drunks.
  Hardly anyone lives here; people come to work and leave.
  Proud, poor and ready to fight about either.
  It floods every spring and everyone has a story about it.
  Nothing here is quite what it seems.
`);

export const PLACES = lines(`
  A ruined watchtower where lights are seen at night
  The old well that is said to grant a wish, once
  A shrine to a forgotten god, still tended by someone
  The hanging tree, and the ravens that live in it
  A library in a converted granary
  The duelling ground behind the chapel
  A sunken garden with a statue nobody recognises
  The flooded crypt beneath the old temple
  A bridge with a toll-keeper who never seems to sleep
  The great clock that runs a quarter-hour slow
  A house that burned three times and was rebuilt three times
  The market cross where proclamations are read
  A bathhouse built over a hot spring
  The fighting pit behind the slaughterhouse
  A walled orchard with a locked gate
  The lighthouse, dark for a decade
  A column carved with the names of the fallen
  The debtors' prison, overcrowded and damp
  An abandoned mint with its vault still sealed
  The college tower where the wizards teach
  A statue of the founder, missing its head
  The fairground and its painted stalls
  A tunnel beneath the walls that everyone denies exists
  The court of justice, with its iron cage outside
  The paupers' graveyard and its silent keeper
  A windmill that turns even on still days
  An old dwarven-cut stair into the hillside
  The guildhall with its gilded weathervane
  A tavern so old the town was built around it
  A fountain whose water tastes faintly of iron
  The gallows square, busy on market days
  An arena for jousts and bear-baiting
  The customs house, full of seized cargo
  The cathedral's unfinished tower
  A menagerie kept by an eccentric noble
  The bell tower that rings for no reason at midnight
  A mausoleum of a family that died out
  The stables of the post riders
  A standing stone in the middle of a street
  The ruins of the first keep, overgrown
`);

export const SHOP_TYPES = [
  { type: 'tavern', label: 'Tavern', specialties: lines(`
      a black ale thick enough to stand a spoon in
      mutton stew that has been simmering for years
      rooms that are clean, which is rare
      a bard who knows every local scandal
      dice games in the back room
      a cellar of wines from far ports
      cheap beds and cheaper company
      a famous hot pie on feast days
      a fireplace big enough to stand in
      spiced cider and roast apples
    `) },
  { type: 'smith', label: 'Smithy', specialties: lines(`
      horseshoes and plough-blades
      swords of honest steel
      locks and iron-bound chests
      armour repair while you wait
      nails, hinges and chain by the yard
      axe heads for woodcutters
      decorative ironwork for the rich
      arrowheads by the barrel
      spearheads for the watch
      tools for the quarrymen
    `) },
  { type: 'general', label: 'General store', specialties: lines(`
      rope, lamp-oil and travel rations
      a bit of everything and most of it dusty
      trail gear for caravans
      second-hand boots and cloaks
      candles, soap and salt
      pots, pans and patched sacks
      maps of the nearby roads, mostly accurate
      goods traded from passing travellers
      winter supplies at summer prices
      whatever came off the last barge
    `) },
  { type: 'apothecary', label: 'Apothecary', specialties: lines(`
      poultices and healing salves
      sleeping draughts and headache powders
      rare herbs from the high meadows
      antidotes, for a price
      tonics that probably do nothing
      bandages, splints and stitching
      perfumes and oils
      remedies for the coughing sickness
      dried roots and mushrooms of every kind
      love charms sold under the counter
    `) },
  { type: 'armourer', label: 'Armourer', specialties: lines(`
      padded jacks and leather armour
      chain shirts, new and mended
      shields painted to order
      helmets of every shape
      plate for knights, made to measure
      cheap armour for levies
      gauntlets and greaves
      scale armour from the south
      armour taken from the battlefield
      horse barding for the rich
    `) },
  { type: 'bowyer', label: 'Bowyer and fletcher', specialties: lines(`
      longbows of yew
      crossbows and bolts
      arrows fletched with goose feathers
      hunting bows for the forest folk
      bowstrings and wax
      quivers of tooled leather
      practice butts and targets
      heavy war arrows
      short bows for riders
      bow repair and re-stringing
    `) },
  { type: 'clothier', label: 'Clothier', specialties: lines(`
      fine cloaks in the latest style
      work clothes that last
      mourning black, always in stock
      embroidered gloves
      boots and shoes made to measure
      dyed wool in bright colours
      travelling clothes for pilgrims
      silk, when the caravans bring it
      furs for winter
      costumes for the players' company
    `) },
  { type: 'magic', label: 'Magic shop', specialties: lines(`
      spell components, sorted and labelled
      scrolls of minor enchantment
      charms against the evil eye
      crystals said to hold power
      potions of dubious origin
      rare inks for spellbooks
      wands, most of them empty
      fortune-telling and readings
      protective amulets
      curiosities from ruined towers
    `) },
  { type: 'stable', label: 'Stable', specialties: lines(`
      horses for hire by the day
      mules and pack animals
      a fine riding horse for sale
      saddles and tack
      stabling for travellers
      ponies for children and dwarves
      draught horses for the farms
      a war-horse too expensive to sell
      fodder and grain
      a farrier on hand
    `) },
  { type: 'jeweller', label: 'Jeweller', specialties: lines(`
      rings and brooches of silver
      gems cut and set
      appraisals, honest or not
      pawned jewellery at a discount
      signet rings for the nobility
      gold chains by weight
      religious medallions
      jewellery taken as debt payment
      pearls from the coast
      repairs to old heirlooms
    `) },
  { type: 'bakery', label: 'Bakery', specialties: lines(`
      black bread and white rolls
      honey cakes on feast days
      meat pies at midday
      hard biscuit for travellers
      bread that is gone by sunrise
      sweet buns with spice
      bread baked with ale
      pastries for the nobility
      the only oven in the district
      loaves stamped with the guild mark
    `) },
  { type: 'scribe', label: 'Scribe', specialties: lines(`
      letters written for those who cannot
      contracts and deeds
      copies of books, slowly
      maps drawn to order
      ink, quills and parchment
      translation of foreign letters
      forgeries, if you ask right
      family histories and genealogies
      notices for the market cross
      wills witnessed and sealed
    `) },
];

export const NPC_ROLES = lines(`
  innkeeper
  blacksmith
  guard sergeant
  priest
  merchant
  fisher
  farmer
  thief
  scholar
  healer
  soldier
  noble
  beggar
  minstrel
  moneylender
  carpenter
  stable-hand
  herbalist
  ferryman
  tax collector
  gravedigger
  miller
  hunter
  tailor
  sailor
  guild clerk
  fortune-teller
  retired adventurer
  city watchman
  smuggler
  baker
  brewer
  mason
  courtesan
  judge
  hedge wizard
  pilgrim
  cook
  rat-catcher
  lamplighter
`);

export const LOOKS = lines(`
  tall and stooped, with ink-stained fingers
  broad as a barrel, with a booming laugh
  thin, sharp-eyed and always moving
  a scar across one cheek and a gentle voice
  missing two fingers on the left hand
  dressed a little too well for the job
  grey-haired but quick on their feet
  covered in flour, or dust, or soot
  young, nervous and eager to please
  weathered by sun and wind
  wears a hat with a single long feather
  heavily tattooed along both arms
  one blue eye and one brown
  never seen without a pipe
  a limp from an old war wound
  bright red hair and freckles
  a voice like gravel in a bucket
  wears too many rings
  soft-spoken and very still
  carries a walking staff carved with runes
  always slightly out of breath
  immaculately clean in a dirty place
  gap-toothed grin, missing an ear
  wrapped in a patched green cloak
  eyes that never quite meet yours
  shaved head and heavy gold earrings
  smells strongly of garlic
  squints as if reading small print
  dressed in mourning, and has been for years
  hands calloused from rope and oar
  stands like a soldier on parade
  ancient and bent, with a clear mind
  smiles with the mouth only
  a nose broken more than once
  paint on their sleeves and in their hair
  wears a holy symbol, polished bright
  chews on a stick of liquorice root
  plump, rosy and suspiciously cheerful
  a long braid wound around the neck
  barefoot, whatever the weather
`);

export const PERSONALITIES = lines(`
  laughs at their own jokes before the end
  cannot resist a wager
  quotes scripture at every chance
  is terrified of dogs
  counts everything twice
  gossips about everyone, including themselves
  trusts nobody who smiles too much
  is extremely polite and extremely cold
  hums the same tune over and over
  collects small, useless objects
  talks to their animals as equals
  never forgets a slight
  gives away more than they can afford
  swears like a sailor
  believes every rumour
  is obsessed with cleanliness
  tells long stories that go nowhere
  flatters everyone shamelessly
  hates the nobility, loves the gossip about them
  is always hungry
  has a nervous cough when lying
  corrects everyone's grammar
  is secretly very brave
  is openly very cowardly
  keeps a diary and writes in it constantly
  loves children and hates adults
  is superstitious about everything
  never sits with their back to a door
  speaks in a whisper, even when shouting would help
  bargains hard even over gifts
  claims to be related to the lord
  forgets names instantly
  is fiercely proud of their trade
  hates magic and anyone who uses it
  is a terrible liar and knows it
  loves a good argument
  is exhausted all the time
  is kind to strangers and cruel to family
  treats every deal as a battle
  prays to a different god each day
`);

export const WANTS = lines(`
  to pay off a debt before it is called in
  to see a son come home from the war
  to find out who poisoned the well
  to marry above their station
  to leave this town forever
  to be elected to the council
  to get revenge on a rival merchant
  to buy back the family land
  to find a cure for a sick child
  to be taken seriously by the guild
  to learn to read
  to see the ocean once
  to prove a brother innocent
  to make a fortune and never work again
  to keep their secret buried
  to be left alone
  to win the heart of someone who ignores them
  to recover a stolen heirloom
  to see the lord deposed
  to join an adventuring company
  to become a wizard's apprentice
  to find the treasure in the old story
  to be forgiven for something long ago
  to escape a marriage they did not choose
  to protect the neighbourhood from the gangs
  to open a shop of their own
  to be remembered after they die
  to find their missing sister
  to destroy the cult that took their friend
  to get the watch off their back
  to see justice done, whatever it costs
  to become rich enough to buy a title
  to pass on their trade before they die
  to find the person who saved their life
  to win the midsummer contest
  to be free of a curse
  to make peace with an old enemy
  to get into the college
  to see the old temple restored
  to keep a promise made to the dead
`);

export const SECRETS = lines(`
  is an informer for the watch
  owes money to the thieves' guild
  is secretly married to a rival's child
  was once a notorious bandit
  knows where the old mint's key is hidden
  is not who they claim to be
  poisoned their business partner
  worships a forbidden god
  is a runaway from a noble family
  is being blackmailed by the moneylender
  saw the murder last winter and said nothing
  has a map to a buried hoard
  sells information to both sides
  is a spy for a foreign power
  hides a fugitive in the cellar
  is dying and has told no one
  is the true heir to the lordship
  stole the relic from the shrine
  can speak with the dead, a little
  started the fire that burned the old quarter
  is planning to rob the tax collector
  is in love with the priest
  has a twin who does the things they are blamed for
  keeps a monster in the basement, and feeds it
  knows the watch captain takes bribes, and has proof
  was cursed by a witch and is changing slowly
  is saving every coin to buy a friend out of slavery
  deserted from the army
  forged the town charter
  has a second family in another town
  is a member of the assassins' guild
  sold the plans to the city walls
  once met a dragon and made a promise to it
  drinks to forget something they did in the war
  is secretly the best swordsman in town
  hides a talent for magic from everyone
  is looking for the person who killed their parents
  has been skimming from the guild for years
  knows a tunnel under the walls
  is a lycanthrope, and it is nearly the full moon
`);

export const CITY_QUIRKS = lines(`
  Every door is painted blue, by an old law nobody remembers the reason for.
  The town bell rings thirteen times at midnight.
  Cats are sacred here, and harming one is a hanging crime.
  Nobody will say the name of the old lord aloud.
  Every house keeps a candle burning in the window on the first of the month.
  The river runs red for a week every spring.
  Strangers must be vouched for by a local within three days.
  There is a festival every new moon, and everyone wears masks.
  The market is held at night, by lantern light.
  Wagons may not enter the town between noon and dusk.
  The dead are buried standing up.
  A sacred goose wanders the streets and must be given right of way.
  Weapons must be peace-bonded at the gate, with red cord.
  Every citizen owes a day of work on the walls each year.
  It is bad luck to whistle within the walls.
  The town is famous for a pie nobody from outside can stomach.
  Duels are legal on the bridge and nowhere else.
  The fountains are said to run with wine on the founder's day.
  The watch are all women, by the founding charter.
  Criminals are sentenced to ring the bell for a day.
  Nobody locks their doors, and nobody steals, officially.
  A great fire is lit every year and a wicker figure burned.
  The town's weather is always a little colder than the land around it.
  Every inn must keep one bed free for a pilgrim.
  Laughter is forbidden in the temple district.
  The streets are named after virtues, and the worst ones after the best.
  Each district has its own dialect, and they tease each other for it.
  There is a crow-counting ritual every morning at the gate.
  The lord's portrait hangs in every tavern, by law.
  Horses are shod with silver for the midsummer procession.
  A mysterious benefactor leaves bread on the church steps each dawn.
  Nobody builds higher than the temple spire.
  Water from the east well is used only for weddings.
  The town keeps a bear, which is paraded on feast days.
  Every child is given a copper coin at birth to keep for life.
  Songs about the last war are banned in taverns.
  The gates are closed for an hour at noon for prayer.
  There is a tradition of leaving gifts for the ghost on the bridge.
  Marriages are only held on rainy days, for luck.
  The town has two names, one for friends and one for strangers.
`);

// Rumours: each is written so it may be true or false; the engine marks it.
export const RUMOURS = lines(`
  {npc} has been seen buying a great deal of rope late at night.
  There is gold hidden somewhere in {place}.
  The {faction} are planning to seize the council.
  A child went missing near {place} and nobody is looking.
  {npc} is not who they claim to be.
  Something is living in the sewers under {district}.
  The well water in {district} is making people sick.
  A dragon was seen over the hills last week.
  {shop} sells stolen goods out of the back room.
  The lord is dying and the heirs are already fighting.
  The watch captain takes bribes from {faction}.
  {npc} knows the way into the old tunnels.
  A plague ship is due in the harbour any day.
  The priest of {place} has lost their faith.
  There will be a new tax before winter.
  {npc} murdered their business partner.
  Bandits are camped two days' ride to the north.
  The {faction} are paying for information about strangers.
  A ghost walks {district} on moonless nights.
  The bridge is unsafe and will fall within the year.
  {shop} waters down everything it sells.
  A wizard is hiring guards for a trip into the ruins.
  Someone has been digging in the cemetery at night.
  {npc} is secretly very rich.
  The army is coming to requisition horses.
  The old mint's vault was never emptied.
  A foreign spy is living in {district}.
  The harvest will fail this year; buy grain now.
  {npc} has a price on their head in another city.
  The {faction} and the lord made a secret deal.
  There is a monster in the lake that eats swimmers.
  A healer in {district} can cure any disease, for a price.
  The temple's relic is a fake; the real one was stolen.
  Somebody is poisoning dogs in {district}.
  {npc} is having an affair with a noble.
  The last traveller who asked about {place} was found in the river.
  Adventurers found a map in {shop} and never came back.
  The walls have a weak spot the watch keeps quiet about.
  A comet next month will bring disaster.
  The founder's tomb is empty.
`);

// Encounters: a d6 per district. General lines, plus a few by district kind.
export const ENCOUNTERS = lines(`
  A pickpocket bumps into a party member.
  A merchant's cart overturns and the goods spill everywhere.
  Two drunks start a fight and try to draw the party in.
  A street preacher warns of doom and points at the party.
  A lost child asks for help finding their parent.
  The watch stops the party to ask their business.
  A dog steals something and runs.
  A beggar offers a tip in exchange for a coin.
  A funeral procession blocks the street.
  Someone empties a chamber pot from a window above.
  A runaway horse charges down the street.
  A noble's carriage splashes mud on everyone.
  A fortune-teller insists on reading someone's palm.
  An argument between two shopkeepers turns violent.
  A stranger slips a note into a party member's hand.
  A wedding party invites everyone to drink.
  A fire breaks out in a nearby building.
  A recruiting sergeant tries to sign someone up.
  A thief is being chased, and asks the party to hide them.
  A cart full of chickens breaks open.
  A local mistakes a party member for someone else.
  A crier announces a reward for a wanted criminal.
  An old soldier tells war stories to anyone who listens.
  A cat follows the party for the rest of the day.
  A shopkeeper offers a "special deal" that is clearly a trap.
  A street performer juggles knives, badly.
  A group of apprentices mock the party's clothes.
  A pilgrim asks for directions to the shrine.
  Someone is selling "genuine" dragon scales.
  The party witnesses a crime and a witness is needed.
  Bells ring an alarm and the gates are closed.
  A collector demands a toll that does not exist.
  A ghostly figure is seen in a window, then gone.
  A physician asks for volunteers for a remedy.
  A duel is about to start and one side needs a second.
  Rain turns the street to mud and everyone takes shelter.
  A procession of monks sings through the crowd.
  A caged animal escapes from a merchant's stall.
  Children play a game that looks disturbingly like a ritual.
  A friendly local offers to guide the party, for a fee.
`);

// Race-tied lines: added to a city only when that race is in its breakdown.
// Keyed by the class ids the catalog uses for the Palladium Fantasy races.
export const RACE_LINES = {
  wolfen: {
    quirks: ['A Wolfen longhouse stands at the edge of town, and its pack guards the north road.',
      'Howling at the full moon is permitted, but only from the Wolfen hill.'],
    shops: [{ type: 'furrier', label: 'Wolfen furrier', specialties: ['cloaks of winter pelts', 'tooth and bone charms', 'hunting spears of the northern style'] }],
  },
  elf: {
    quirks: ['The elves keep a grove within the walls where no axe may enter.',
      'Elven songs are sung at every funeral, whoever died.'],
    shops: [{ type: 'elven-crafts', label: 'Elven craftshop', specialties: ['bows of living wood', 'silver leaf jewellery', 'cloaks that blend with the forest'] }],
  },
  dwarf: {
    quirks: ['The dwarves have dug beneath the town, and nobody knows how far.',
      'A dwarven clock in the square is never more than a second wrong.'],
    shops: [{ type: 'dwarven-forge', label: 'Dwarven forge', specialties: ['axes that hold an edge for a lifetime', 'engraved armour', 'mining gear and lanterns'] }],
  },
  orc: {
    quirks: ['An orc tribe trades at the gate each new moon, under an old truce.'],
    shops: [{ type: 'orc-trader', label: 'Orc trader', specialties: ['hides and bone', 'crude but heavy weapons', 'mushrooms from the deep caves'] }],
  },
  ogre: {
    quirks: ['An ogre works the town crane, and is paid in bread and beer.'],
    shops: [],
  },
  goblin: {
    quirks: ['Goblins run the town\'s rubbish carts, and know every secret thrown out.'],
    shops: [{ type: 'goblin-junk', label: 'Goblin junk-shop', specialties: ['anything anyone threw away', 'traps of every size', 'strange mechanical toys'] }],
  },
  gnome: {
    quirks: ['A gnome clockmaker has filled the town with small moving figures.'],
    shops: [{ type: 'gnome-tinker', label: 'Gnome tinker', specialties: ['clockwork and gears', 'repair of anything', 'gemstone polishing'] }],
  },
  troll: {
    quirks: ['A troll collects the bridge toll, legally, under a charter nobody can find.'],
    shops: [],
  },
};

// A city's own name when no pool supplies one: a prefix and a suffix.
export const CITY_NAME = {
  pre: lines(`
    Ash\nBarrow\nBlack\nBright\nBrook\nCastle\nCold\nDeep\nDun\nEast\nElm\nFair\nFen\nFrost\nGold\nGreen
    Grey\nHart\nHawk\nHigh\nIron\nKing\nLong\nMarsh\nMill\nMoor\nNew\nNorth\nOak\nOld\nRaven\nRed\nRiver\nRock
    Salt\nSilver\nStone\nThorn\nWest\nWhite\nWillow\nWolf`),
  suf: lines(`
    bridge\nbrook\nburg\nbury\ncaster\ncombe\ncross\ndale\nden\nfield\nford\ngate\nhall\nham\nhaven\nhill\nholm
    hurst\nley\nmere\nmoor\nmouth\nport\nstead\nstoke\nton\nwall\nwater\nwick\nwood\nworth\nfall\nreach\nhold
    march\nwatch\nspire\nkeep\nfort\nvale`),
};

// Which people theme names each race, when no AI pool is in play. A race not
// listed takes the setting's default.
export const RACE_NAME_THEMES = {
  human: 'pf-eastern-territory', noble: 'pf-western-empire',
  wolfen: 'pf-wolfen', elf: 'pf-elf', changeling: 'pf-elf',
  dwarf: 'pf-dwarf', gnome: 'pf-dwarf',
  orc: 'pf-orc-ogre', ogre: 'pf-orc-ogre', troll: 'pf-orc-ogre', goblin: 'pf-orc-ogre',
  'hob-goblin': 'pf-orc-ogre', kobold: 'pf-orc-ogre', troglodyte: 'pf-orc-ogre',
};
export const DEFAULT_PEOPLE_THEME = 'pf-eastern-territory';
export const PLACES_THEME = 'pf-places';
