// The City Creator's Rifts tables - every line a Rifts city is built from,
// apart from its names (shared/js/namegen.js's Rifts themes, or the AI name
// pool). The same shape as city-tables-pf.js, and the engine reads whichever
// file the city's `system` names.
//
// ALL OF IT WAS WRITTEN FOR THIS FILE. Nothing is copied from a sourcebook or
// an OCR cache, and no book text is committed here. Names of the setting's
// powers (the Coalition, Northern Gun, Techno-Wizards) are the setting's
// vocabulary; every sentence around them is new.
//
// SIZE IS THE POINT, as it is for Palladium Fantasy: 40 or more entries per
// table, read back by a smoke check rather than trusted from this comment.
//
// What Rifts adds to the overview (OVERVIEW_EXTRAS): a tech level, how much
// the Coalition is here, and the ley lines. Walls are M.D.C. walls, because
// in a world of Mega-Damage anything less is decoration.
//
// Slots, as in the Palladium Fantasy file:
//   {npc} {district} {place} {shop} {faction} {race} {city}
// A line with a slot the city cannot fill is skipped, never filled with a
// stand-in.

const lines = (s) => s.split('\n').map((x) => x.trim()).filter(Boolean);

export const CURRENCY = 'cr';

// Rifts humans take an O.C.C. and have no R.C.C. of their own, so the race
// list (the setting's published R.C.C.s) is given a Human row, and a human
// NPC rolls as their job's O.C.C. alone. Many Rifts R.C.C.s take no O.C.C.
// and roll alone; the ones that do (a Noro, a Psi-Pony) are marked on their
// race row by the page, from the roller's own rule.
export const HUMAN = { id: 'human', name: 'Human' };
export const RACE_TAKES_OCC = false;

export const SIZES = [
  { id: 'hamlet', label: 'Outpost', max: 99, suggest: 60,
    districts: [1, 1], shops: [1, 2], places: [1, 2], factions: [0, 1], walls: 0.3 },
  { id: 'village', label: 'Settlement', max: 999, suggest: 450,
    districts: [2, 3], shops: [3, 5], places: [2, 3], factions: [1, 2], walls: 0.6 },
  { id: 'town', label: 'Town', max: 4999, suggest: 2500,
    districts: [3, 4], shops: [6, 9], places: [4, 6], factions: [2, 2], walls: 0.85 },
  { id: 'city', label: 'City', max: 24999, suggest: 12000,
    districts: [5, 7], shops: [10, 14], places: [6, 9], factions: [2, 3], walls: 1 },
  { id: 'metropolis', label: 'Mega-city', max: Infinity, suggest: 60000,
    districts: [8, 10], shops: [15, 20], places: [9, 12], factions: [3, 3], walls: 1 },
];

export const WEALTH = [
  { id: 'destitute', label: 'Destitute', price: 0.7, line: 'Credits are rumours here; trade is in food, ammo and favours.' },
  { id: 'poor', label: 'Poor', price: 0.85, line: 'A working E-Clip is worth a week\'s wages.' },
  { id: 'modest', label: 'Modest', price: 1, line: 'Power, water and a market that opens most days.' },
  { id: 'prosperous', label: 'Prosperous', price: 1.3, line: 'Hover traffic, new armour, and merchants who take universal credits.' },
  { id: 'rich', label: 'Rich', price: 1.6, line: 'Towers, shields and money old enough to remember the Coming of the Rifts.' },
];

export const PRICE_LEVELS = ['cheap', 'fair', 'fair', 'steep', 'robbery'];

export const WALLS = lines(`
  a ring of stacked M.D.C. cargo containers, welded and gun-slotted
  a poured mega-damage concrete wall with four armoured gates
  a salvaged wall of pre-Rifts highway barriers faced with M.D.C. ceramic plate
  a double M.D.C. wall with a killing ground of razor wire between
  an old military M.D.C. blast wall, patched with alloy from a downed airship
  earthworks faced with M.D.C. plate and topped with auto-turrets
  a wall of wrecked M.D.C. robot hulls, their weapon mounts still manned
  an M.D.C. wall with a force-field fed by a humming ley line generator
  a stone wall made M.D.C. by Techno-Wizard wards that glow at night
  an M.D.C. palisade of alloy pylons and chain-mesh
  a high wall of Northern Gun modular M.D.C. panels, bought on credit
  a crumbling wall the town outgrew, with a newer M.D.C. one half-built beyond it
`);

export const GOVERNMENTS = lines(`
  a mayor elected by show of hands at the gate
  a council of the families who first dug out the ruins
  a warlord whose power armour is parked outside the town hall
  a merchant company that owns the water and so owns the town
  a retired Cyber-Knight everyone agreed to obey
  a Coalition-appointed administrator and a nervous staff
  a council of Techno-Wizards who keep the lights on
  a sheriff and whatever deputies the town can pay this month
  a mercenary company that took the job and never left
  a town meeting that has run, in shifts, for eleven years
  a trio of gang bosses who divided the town by street
  a local faith that preaches the Rifts are a judgement
  a co-operative of farmers and mechanics who vote on everything
  an artificial intelligence nobody has seen, speaking through a terminal
  a noble family of D-Bees that claims the land by treaty
  a bandit king who calls it protection
  the owner of the only working fusion plant
  a council of elders who remember the first rifts opening
  a Northern Gun factory manager with a company charter
  a psychic who can tell when anyone is lying, and does
  a mercenary general's widow, who runs things better than the general did
  the captain of the militia and nobody else
  a mystic who reads the ley lines before every decision
  an alliance of trading posts that rotate the chair every season
  a Black Market fixer who technically holds no office at all
  a dragon who took the town as a hobby
  a guild of salvagers who own everything worth owning
  a council split evenly between humans and D-Bees
  a former Coalition officer who deserted with a whole platoon
  a revolving committee of whoever survived the last raid
  an old pre-Rifts city charter, enforced by a robot bailiff
  a preacher, a banker and a gunsmith who meet in the saloon
  a gene-splicer who cured the town's plague and stayed
  a ley line walker who can close the gate rift, and so is obeyed
  a kid who inherited the job from a bounty hunter
  a chain of command left over from a pre-Rifts military base
  the bar's owner, because the bar is the only building that never fell
  a union of rail-workers who keep the old line running
  a pair of feuding twins who each claim to be mayor
  a distant lord of the free cities who visits once a year
  an elected judge who also runs the jail and the bank
  a Coalition collaborator no one dares remove
`);

export const TRADES = lines(`
  salvage from a pre-Rifts city buried under the hills
  a working fusion plant that sells power by the line
  water, pumped from an aquifer nobody else can reach
  weapons repair for every merc who passes through
  a Northern Gun distribution depot
  cybernetics, legal and otherwise
  E-Clip recharging at fair prices
  hides and meat from monsters hunted in the swamps
  a rail line that still runs, twice a week
  ley line energy, tapped and sold to Techno-Wizards
  refugees, who work the fields for passage further north
  crops grown under hydroponic domes
  a Black Market clearing house
  scrap robots, stripped and resold by weight
  horses and mutant riding beasts
  pre-Rifts books and data discs, sold to scholars
  a mercenary hiring hall
  armour plating stamped from salvaged hulls
  salt and fish from a lake that glows at night
  a trading post on the only safe road east
  mining a vein of strange metal from a dimensional rift
  Juicer clinics, which ask no questions
  guiding caravans through the Magic Zone
  a crystal quarry prized by Techno-Wizards
  medicine made from local herbs and alien castoffs
  an airfield for hover traffic and old jet craft
  distilling fuel for anyone who still burns it
  bounty hunting, with a posting board in the square
  alloy smelting from wreckage the river brings down
  a pilgrims' shrine at a ley line nexus
  training schools for would-be mercenaries
  bartering with a nearby D-Bee community
  repairing power armour, no matter whose
  raising Dog Boy puppies for the Coalition, under contract
  fortune-telling and ley line readings for travellers
  the lumber of a forest that grows back overnight
  tinkering robots and drones from spare parts
  a gladiator arena that draws crowds from three states
  a free port where anyone's credits are good
  livestock raised on land cleared of monsters
  translation and brokering between human and alien traders
  a hot spring said to heal radiation sickness
`);

export const FACTIONS = lines(`
  The Gate Wardens, who decide who gets in
  The Salvage Guild, who own every ruin in a day's walk
  The Coalition sympathisers, who meet in plain sight
  The Free D-Bee League, who want equal votes
  The Ley Line Circle, who want the nexus kept pure
  The Iron Saints, who want the gangs to keep a code of honour
  The Waterholders, who want to control the pumps for good
  The Pure Blood Society, who want every D-Bee gone
  The Brothers of the Last Light, who want salvation through technology
  The Black Market, who want trade kept quiet
  The Juicer Club, who want pay, glory and a short bright life
  The Old Families, who were here before the walls
  The Refugee Council, who speak for the newcomers
  The Cyber-Knights of the south road, who keep the peace their way
  The Merchants' Compact, who want stable prices and quiet streets
  The Techno-Wizard lodge, who want the ley line tapped harder
  The Mothers of the Wall, who keep the militia fed
  The Scrap Kings, who run the junkyards and the chop-shops
  The Night Patrol, who hunt criminals in power armour
  The Truth Seekers, who hunt pre-Rifts knowledge
  The Gene-Clean Movement, who fear mutation above all
  The Arena Masters, who own the fighters and the betting
  The Railway Brotherhood, who keep the trains moving
  The Crows, who sell secrets to anyone
  The Border Riders, who patrol the badlands for a fee
  The Sisters of Mercy, who run the clinic and the orphanage
  The Northern Gun agents, who want a monopoly on arms
  The Wanderers, who protect the town's psychics
  The Free Press, who print what the council hides
  The Burnt Hand, who were Coalition soldiers once
  The Glow Priests, who worship the rifts themselves
  The Farmers' Union, who want protection from raiders
  The Hunters' Lodge, who clear monsters for bounty
  The Machine Cult, who believe the robots are alive
  The Temperance League, who want Juice and Crash banned
  The Envoys, who speak for a D-Bee kingdom across the river
  The Dead Boys' Widows, who want the Coalition to pay
  The Sky Harbour Guild, who control the hover traffic
  The Deep Diggers, who mine under the town
  The Lightkeepers, who keep the street lamps and the gossip
  The Magic-Free Committee, who want every spellcaster registered
  The Tinkers' Row, who fix anything for anyone
`);

export const DISTRICT_KINDS = lines(`
  Gate District
  Salvage Yards
  Old Downtown
  The Market Deck
  Hover Harbour
  Factory Row
  Tent City
  The Nexus Quarter
  Militia Barracks
  The Arena
  Hydroponic Farms
  Pumphouse Ward
  The Underground
  Chop-Shop Alley
  Ruins Edge
  Rail Yards
  Clinic Row
  The Stacks
  Merc Town
  Refugee Camp
  Power Plant Ward
  Scrapheap Hill
  The Glass Streets
  Techno-Wizard Row
  Old Military Base
  The Bazaar
  Shanty Rows
  The Heights
  Dock Ward
  The Crater
  Bunker District
  Cathedral Ward
  The Dome
  Satellite Village
  Wreck Field
  The Strip
  Warehouse District
  The Hollow
  Signal Hill
  Ley Walk
  Traders' Rest
  Old Suburbs
`);

export const MOODS = lines(`
  loud with generators and louder with people
  quiet, watchful, every window a firing slit
  thick with the smell of hot metal and ozone
  bright at night with neon scavenged from the ruins
  crowded with refugees who arrived last week
  prosperous and nervous about staying that way
  half-empty since the last raid
  bustling from dawn until the curfew siren
  suspicious of strangers and armed about it
  cheerful in the way of people who expect to die young
  soaked in rain that never quite stops
  humming with ley line energy that makes teeth ache
  grim, patched and stubborn
  full of mercs spending their pay as fast as they can
  proud of its walls and prouder of its guns
  dusty, sunbaked and slow
  tense, with militia on every corner
  festive, with a market day every day
  haunted by the pre-Rifts ruins it is built on
  run-down, but everyone knows everyone
  noisy with hover traffic and hawkers
  clean, orderly and slightly too polite
  dim, with power cut to every other street
  dangerous after dark and not much better by day
  pious, with shrines on every doorstep
  mechanical, where even the children fix things
  green with gardens planted in old car hulls
  tired, and waiting for something to change
  cosmopolitan, with a dozen species at every bar
  hard-bitten, where a handshake is a contract
  secretive, where every shop has a back room
  cold, grey and blown by winds off the badlands
  eerie, where the ley line glows through the fog
  hopeful, rebuilding after the last disaster
  smug about being the safest place for fifty miles
  crowded with stalls selling things that should not exist
  choked with scrap and the people who live in it
  sleepy until the caravans arrive
  loud with arena crowds every evening
  bristling with antennas and sensor dishes
  sweltering and humid from the steam vents
  divided, with human and D-Bee streets side by side
`);

export const PLACES = lines(`
  The gate rift, sealed but still humming
  A crashed Coalition troop transport, stripped to the ribs
  The water tower painted with every gang's sign
  A pre-Rifts library with one reading room still dry
  The ley line nexus stone, fenced and guarded
  A monument to the militia who held the last siege
  The old parking garage, now eight floors of market
  A working pre-Rifts traffic light no one dares turn off
  The mercenary hiring board, covered in names and prices
  A shrine to a god from another dimension
  The arena, built in a flooded stadium
  The fusion plant's cooling towers
  A robot graveyard, where children play among giants
  The radio mast that talks to the next three towns
  The bounty board, with a reward on someone local
  A bunker where the first families sheltered
  A crater where something fell from the sky
  The hydroponic domes, glowing green at night
  The jail, a converted bank vault
  A statue of a pre-Rifts president, missing its head
  The landing pad, scorched black
  A cemetery where the dead are buried in their armour
  An old cathedral turned into a clinic
  The Techno-Wizard tower, crackling with blue light
  The train station, with one working locomotive
  A pre-Rifts theme park ride, rusted into a landmark
  The water purification plant
  The flea market under the collapsed overpass
  A sealed pre-Rifts vault nobody can open
  The old highway bridge, patched with M.D.C. plate
  The militia armoury
  A glowing pool where a rift once opened
  The Dog Boy kennels outside the Coalition post
  A ruined mall, now a warren of homes
  The gallows, which the town is not proud of
  The radar dome on the hill
  A wall of photographs of the missing
  The chop-shop with the biggest crane in town
  A pre-Rifts school, now the town hall
  The old satellite dish, pointed at nothing
  The ferry landing on the river
  A burned-out Northern Gun showroom
`);

export const SHOP_TYPES = [
  { type: 'tavern', label: 'Bar', specialties: lines(`
      a beer brewed from mutant grain that tastes almost normal
      a jukebox with forty pre-Rifts songs and a fist-fight over each
      rooms upstairs rented by the hour or the week
      a gambling table for mercs with fresh pay
      the only real coffee for a hundred miles
      a bartender who knows every bounty in town
      a cage-fight every Saturday
      a stew of whatever the hunters brought in
      rotgut strong enough to strip paint
      a quiet back booth for deals that never happened
    `) },
  { type: 'gunshop', label: 'Gun shop', names: ['Guns', 'Arms', 'Armory', 'Firearms', 'Ammo', 'Hardware', 'Lasers'], specialties: lines(`
      Northern Gun lasers, new and nearly new
      old-fashioned slug-throwers for the Magic Zone
      E-Clip recharging while you wait
      rail gun parts and ammunition drums
      custom paint and engraving on any weapon
      rebuilt Coalition rifles with the serial numbers ground off
      precision lasers for those who can afford them
      grenades sold by the crate
      holdout pistols small enough to hide in a boot
      vibro-blades and energy melee weapons
    `) },
  { type: 'armour', label: 'Armour shop', names: ['Armour', 'Plate', 'Hardsuits', 'Shells', 'Body Armour'], specialties: lines(`
      environmental body armour fitted while you wait
      M.D.C. plate repair and re-sealing
      urban armour disguised as ordinary clothes
      riot suits for militia and bouncers
      armour for D-Bees of unusual shapes
      second-hand armour with the dents left in
      helmets with built-in optics
      padded armour for scouts who need to move quietly
      full environmental suits for the badlands
      armour painted in any gang's colours
    `) },
  { type: 'bodychop', label: 'Body-chop-shop', names: ['Cybernetics', 'Bionics', 'Chop Shop', 'Implants', 'Body Works', 'Augments'], specialties: lines(`
      cybernetic eyes and ears, installed the same day
      bionic arm attachments for miners and fighters
      implants with no records kept
      repairs to borgs whose owners cannot pay
      sensor implants for scouts and hunters
      cheap replacement limbs for accident victims
      a doctor who once worked in Chi-Town
      weapon housings built into the forearm
      removal of Coalition tracking implants
      hydraulic hands for heavy labour
    `) },
  { type: 'general', label: 'General store', names: ['Supply', 'Goods', 'Provisions', 'Trading Post', 'Sundries', 'Surplus'], specialties: lines(`
      backpacks, rope and everything for the road
      survival kits for travellers heading into the wilds
      canned food from before the Coming of the Rifts
      tents and sleeping bags rated for the badlands
      tool kits for every kind of repair
      flashlights, flares and batteries
      canteens and water purifiers
      a bit of everything, and a rat in the back room
      goods traded from three dimensions
      whatever the caravan brought last week
    `) },
  { type: 'tw', label: 'Techno-Wizard shop', names: ['Techno-Wizardry', 'Crystals', 'Mystic Works', 'Wands', 'Arcane Tech', 'Spellworks'], specialties: lines(`
      guns that fire lightning instead of lasers
      crystals charged at the ley line
      converted energy weapons that never need an E-Clip
      grenades with magic inside them
      charms that keep the Magic Zone's weirdness at bay
      repairs to anything that runs on P.P.E.
      hover gear powered by a singing crystal
      a waiting list for custom work
      revolvers that never run out of shots
      devices whose use the owner will not explain
    `) },
  { type: 'vehicles', label: 'Vehicle lot', names: ['Motors', 'Hover Lot', 'Garage', 'Rides', 'Wheels', 'Autos'], specialties: lines(`
      hovercycles, new, used and stolen
      ATVs for the badlands
      rebuilt pre-Rifts jeeps
      fuel, fusion cells and spare parts
      boats for the river trade
      a jet pack or two, lightly used
      motorcycles tuned for the open road
      armoured transport for caravans
      anything with an engine, bought for cash
      a workshop that fixes what it cannot sell
    `) },
  { type: 'clinic', label: 'Medical clinic', names: ['Clinic', 'Medical', 'Infirmary', 'Healers', 'Med-Center', 'Surgery'], specialties: lines(`
      field surgery for mercs who cannot stop bleeding
      robot medical kits and nano-healers
      radiation treatment for scavengers
      a doctor who treats humans and D-Bees alike
      antibiotics grown in the back room
      prosthetics fitted at cost
      no questions asked, no records kept
      a psychic healer on call
      surgery on anything that walks in
      healing salves from local herbs
    `) },
  { type: 'electronics', label: 'Electronics shop', names: ['Electronics', 'Comms', 'Circuits', 'Sensors', 'Radio', 'Tech Exchange'], specialties: lines(`
      radios and communicators of every range
      portable computers and data discs
      sensors for scouts and bounty hunters
      jammers and scramblers, for the careful
      pre-Rifts gadgets cleaned and repaired
      cameras and recorders for the curious
      language translators for talking to D-Bees
      radar sets salvaged from aircraft
      tracer bugs and the tools to find them
      a repair counter with a two-week queue
    `) },
  { type: 'outfitter', label: 'Outfitter', names: ['Outfitters', 'Clothing', 'Gear', 'Wear', 'Threads', 'Tailors'], specialties: lines(`
      clothes for the badlands and the city alike
      boots that last a thousand miles
      gas masks and air filters for the toxic zones
      fatigues in every camouflage pattern
      goggles against sandstorm and sun
      cold weather gear for the northern routes
      cloaks and robes for travellers who would rather not be seen
      uniforms for any militia that can pay
      gloves, belts and holsters
      dress clothes for a night at the arena
    `) },
  { type: 'magic', label: 'Magic shop', names: ['Magic', 'Arcana', 'Curios', 'Oddities', 'Relics', 'Wonders'], specialties: lines(`
      fetishes and charms of the local shamans
      parts of monsters, sold for purposes best left unasked
      rune weapons, when one can be found
      enchanted armour from another dimension
      protection stones and healing stones
      items from Atlantis, with no questions asked
      a reader who can tell what an item does
      magic trinkets traded from travellers
      spell gems and crystals
      things that belong in a museum, or a fire
    `) },
];

// A shop's name is built from its kind's `names` above and these, so the
// name says what the shop sells (city-engine.js, names.shop). Taverns have no
// `names`: the places theme's tavern names already read as taverns.
export const SHOP_ADJECTIVES = ['Iron', 'Chrome', 'Rusty', 'Neon', 'Lucky', 'Last', 'Free', 'Burning', 'Blue', 'Red', 'Black', 'Steel', 'Wild', 'Honest', 'Silver', 'Broken', 'Crooked', 'Old', 'New', 'Northern', 'Frontier', 'Big', 'Busted', 'Dusty', 'Shining', 'Golden', 'Plasma', 'Atomic', 'Rolling', 'Lonesome'];

export const NPC_ROLES = lines(`
  bartender
  gunsmith
  militia sergeant
  preacher
  merchant
  salvager
  farmer
  thief
  scholar
  medic
  mercenary
  town elder
  beggar
  musician
  moneylender
  mechanic
  stable-hand
  herbalist
  ferry pilot
  tax collector
  gravedigger
  water engineer
  bounty hunter
  tailor
  river trader
  radio operator
  fortune-teller
  retired adventurer
  gate guard
  smuggler
  cook
  brewer
  builder
  arena fighter
  judge
  hedge mage
  pilgrim
  rat-catcher
  street-lamp keeper
  junk dealer
  caravan scout
  schoolteacher
`);

export const LOOKS = lines(`
  scarred from a laser burn across one cheek
  wears a battered Coalition helmet with the skull scratched off
  one cybernetic eye that whirrs when it focuses
  tall and gaunt, in a long duster coat
  covered in tattoos of every town they have lived in
  wears armour that is more patches than plate
  bald, with a ley line tattoo glowing faintly on the scalp
  small and wiry, with grease on everything
  wears sunglasses, day and night
  broad-shouldered, with a bionic arm painted red
  young, with old, tired eyes
  missing two fingers and does not talk about it
  dressed in a pre-Rifts suit, carefully mended
  smells of ozone and cheap cigarettes
  has a Dog Boy's collar hanging from their belt
  wears a necklace of teeth from something big
  freckled, sunburnt and cheerful
  carries a sidearm in plain sight at all times
  hair dyed a colour that does not occur in nature
  wears a militia badge that has seen better days
  walks with a limp and a very good cane
  has a voice like gravel in a blender
  dressed all in black, head to boots
  wears a heavy coat lined with pockets
  has a scar where a Juicer tried to strangle them
  wears glasses held together with wire
  immaculately clean in a very dirty town
  thin as a rail, with nervous hands
  carries a data slate everywhere
  wears a hat older than the town
  has one arm in a sling and a smile on their face
  weathered by the badland sun
  has pale, glowing eyes from a psychic awakening
  wears a crucifix and a laser pistol
  huge, and far gentler than they look
  wears jewellery made of circuit boards
  always chewing something
  has a pet that is not quite any known animal
  wears cowboy boots and a wide hat
  bruised from a fight they claim to have won
  has a missing ear and a very good hearing implant
  covered in fine scars from shrapnel
`);

export const PERSONALITIES = lines(`
  is suspicious of anyone who asks questions
  laughs too loudly at their own jokes
  never forgets a debt, owed or owing
  quotes pre-Rifts films nobody else has seen
  is kind to D-Bees and cold to Coalition soldiers
  trusts machines more than people
  is brave to the point of stupidity
  hoards anything that might be useful
  talks to their gun
  is polite to a fault and dangerous when crossed
  believes every rumour they hear
  is fiercely loyal to the town
  gambles away everything on the arena fights
  hates magic and says so often
  is endlessly curious about other dimensions
  never sits with their back to a window, since the sniper years
  is cheerful in a way that unsettles people
  keeps a list of everyone who has wronged them
  is sure the Coalition is coming for them
  is soft-hearted about strays of every kind
  speaks in short, clipped sentences
  lies for practice
  is proud of the scars they have earned
  wants everyone to like them
  prays before every meal and every fight
  is quick to anger and quicker to forgive
  has an opinion on every weapon ever made
  is terrified of psychics
  collects pre-Rifts coins
  is secretly lonely
  always carries a spare E-Clip, just in case
  is haunted by a battle they survived
  thinks they are funnier than they are
  is ruthless in business and generous in private
  refuses to pay full price for anything
  treats every stranger as a customer
  scrubs radiation dust off everything, twice
  never drinks, and watches those who do
  whistles when nervous
  is fascinated by magic and afraid to try it
  thinks the rifts are a punishment from heaven
  sees every problem as something to fix
`);

export const WANTS = lines(`
  to buy a suit of real power armour
  to find a child taken by raiders
  to get out of town before the Coalition arrives
  to win a seat on the council before the Coalition picks one
  to open a second shop across the river
  to pay off a debt to the Black Market
  to learn magic without anyone knowing
  to find the pre-Rifts vault a grandparent described
  revenge on the gang that burned their farm
  to marry someone the family does not approve of
  to get their cybernetics removed
  to prove they are not a coward
  to find a cure for a strange illness
  to see the ocean before they die
  to become a Cyber-Knight
  to sell up and retire
  to find out what came through the last rift
  to drive the D-Bees out, or to make them welcome
  to win a fight in the arena
  to find a new source of clean water
  to be left alone with their radio and their dog
  to replace a worn-out bionic arm
  to steal from the richest person in town
  to recover a family heirloom sold by mistake
  to get their name off a bounty board
  to see justice done for a murdered friend
  to reach one of the free cities of the north
  to buy a Techno-Wizard weapon
  to make peace between two gangs
  to find the one who sold them out
  to discover who their parents were
  to protect the town from a coming raid
  to build a school
  to get rich before the next war
  to earn the respect of the militia
  to find a cure for Juicer burnout
  to get a message to someone in Chi-Town
  to recover a lost shipment of E-Clips
  to be free of a psychic who controls them
  to hunt the monster that killed their partner
  to see a real pre-Rifts city
  to leave something that will last
`);

export const SECRETS = lines(`
  is an informant for the Coalition
  is a D-Bee hiding under a human disguise
  deserted from a Coalition army unit
  has a psychic power they keep hidden
  owes money to a Splugorth slaver
  killed their former partner
  secretly practises magic
  stole the money they built their business with
  has a price on their head in another state
  is a Juicer, and their time is almost up
  hides a fugitive in their cellar
  sells weapons to the raiders
  is in love with a gang boss
  knows the combination to a pre-Rifts vault
  once served a dragon
  is being blackmailed by the mayor
  has a Coalition tracking implant they cannot remove
  is not who they say they are
  lost a child to the rifts and still searches
  is plotting to seize the water supply
  is a spy for a rival town
  can hear the ley line talking
  sold out a caravan to bandits
  keeps a forbidden book of magic under the floor
  has a second family in a D-Bee settlement across the river
  is dying slowly and tells no one
  was once a slaver
  is heir to a pre-Rifts fortune
  is working to bring the Coalition here
  hides a stolen Northern Gun prototype
  knows who really killed the old mayor
  was born on another world
  has made a deal with a demon
  escaped from a gene-splicer's laboratory
  is the one who opened the last rift
  poisoned the well last winter
  has a secret stash of Juice
  is a member of the Pure Blood Society
  reports to the Black Market
  was once a Cyber-Knight, and fell
  knows where a crashed alien craft lies
  is plotting to assassinate a council member
`);

export const CITY_QUIRKS = lines(`
  The curfew siren sounds at dusk, and the gates close with it.
  Every citizen serves one week a year on the wall.
  Magic is legal, but every spellcaster must register at the town hall.
  The water is safe, but it glows faintly at night.
  The whole town turns out for arena fights, and business stops.
  D-Bees and humans drink at separate bars, by old custom.
  Weapons must be peace-bonded inside the walls.
  A robot bailiff patrols the market and cannot be reasoned with.
  The ley line surges every full moon, and the lights go strange.
  The town radio plays pre-Rifts music every evening.
  Every building has a bomb shelter, and they are all connected.
  Bounties are posted in the square, and paid on the spot.
  A Coalition patrol passes through every week, and everyone behaves.
  The mayor settles disputes by arm-wrestling.
  Nobody talks about the thing that lives in the old subway.
  The town was built on a pre-Rifts military base, and the base still has secrets.
  Hover traffic is banned from Main Street.
  The market sells everything except people, and that rule is enforced by death.
  The militia is voluntary, and nearly everyone volunteers.
  A dragon visits once a year, and the town pays tribute.
  The town's founder is buried under the fountain.
  Children are taught to shoot before they learn to read.
  Every newcomer is tested by a psychic at the gate.
  The walls are painted with the names of the dead.
  Credits are accepted, but most trade is still barter.
  The pre-Rifts clock on the town hall still keeps perfect time.
  A Techno-Wizard lamp lights every street corner.
  A festival marks the day the rift closed, every year.
  There is a law against selling Juice, and a thriving trade in it.
  The graveyard is guarded, because the dead do not always stay down.
  Every dispute between humans and D-Bees goes to a mixed jury.
  The sheriff has held the job for forty years.
  A Northern Gun factory offers jobs to anyone who can pass the test.
  The town gate is the head of an old Coalition war machine.
  Every house flies a flag showing whom it will shelter.
  The river is fished by day and avoided by night.
  An old AI speaks through public terminals, answering questions.
  Salvage rights are auctioned every spring.
  Everyone knows the password to the back room, and it changes daily.
  The town has declared itself neutral, loudly and often.
  A Cyber-Knight is always welcome to free room and board.
  A monument honours the Coalition soldiers who died defending the town.
`);

export const RUMOURS = lines(`
  {npc} is selling information to the Coalition.
  A pre-Rifts vault lies under {place}, and it is still sealed.
  The Coalition plans to annex {city} before winter.
  {faction} is buying up every E-Clip in town.
  A monster has been seen near {place} after dark.
  {npc} is a D-Bee in disguise.
  The water supply is being poisoned by {faction}.
  {shop} sells weapons stolen from the militia.
  A new rift is about to open near {district}.
  {npc} knows the way to a crashed Coalition airship.
  The mayor has made a secret deal with raiders.
  {faction} is planning to take over the council.
  A Techno-Wizard in {district} has built something dangerous.
  {npc} is a Juicer, and their time is running out.
  The arena fights are fixed by {faction}.
  A bounty hunter has arrived looking for {npc}.
  The ley line is getting stronger, and no one knows why.
  {shop} has a back room full of Black Market goods.
  A dragon has been seen flying over {district}.
  {npc} was once a Cyber-Knight.
  Someone is kidnapping D-Bees from {district}.
  The Coalition has a spy in the militia.
  {place} is haunted by the ghost of a pre-Rifts soldier.
  {faction} is smuggling Juice into town.
  {npc} is secretly working for a rival town.
  An old robot in {place} still has live weapons.
  {shop} is a front for a ring of psychics.
  The last raid was an inside job.
  {npc} has a stash of pre-Rifts gold.
  A caravan is overdue, and {faction} knows why.
  {district} is built on top of a Coalition mass grave.
  {npc} can open the gate rift.
  The Splugorth have an agent in {city}.
  {faction} is building a private army.
  A cure for Juicer burnout is being sold at {shop}.
  {npc} is plotting to kill the mayor.
  The walls around {district} will not hold another siege.
  A psychic child was born in {district}, and everyone wants them.
  {place} was once a Coalition interrogation site.
  {npc} saw something come out of the ley line.
  {faction} has made an alliance with a band of raiders.
  The old AI knows more than it says.
`);

export const ENCOUNTERS = lines(`
  A Juicer picks a fight with the biggest person in sight.
  A Coalition patrol stops everyone for identity checks.
  A street preacher warns that the rifts are the end of days.
  A child offers to sell a working pre-Rifts gadget.
  A hover bike crashes into a market stall.
  A D-Bee merchant is being harassed by a mob.
  A bounty hunter drags a captive through the street.
  The ley line flares, and every light flickers blue.
  A stray Dog Boy sniffs out something in the rubble.
  A mechanic asks for help lifting an engine block.
  A salesman demonstrates a laser rifle, a little too close.
  A psychic stops the party and says their names.
  A power cut plunges the district into darkness.
  A crowd gathers to watch two mercs duel with vibro-blades.
  A caravan arrives, and the whole street comes out to trade.
  A robot sweeper insists on checking the party's boots.
  A wounded stranger begs for a doctor.
  A pickpocket with a cybernetic hand tries their luck.
  A militia sergeant recruits for a dangerous job.
  A mutant animal escapes from a butcher's cage.
  A sandstorm rolls over the wall, and everyone runs for shelter.
  A gang demands a toll to pass through their street.
  An old woman offers to read the party's future in the ley line.
  A drone buzzes overhead, filming everything.
  A merchant offers a map to a pre-Rifts vault, cheap.
  Gunfire breaks out two streets away.
  A Techno-Wizard's experiment goes wrong in a shower of sparks.
  A group of refugees asks the way to the clinic.
  A tired Cyber-Knight asks if anyone has seen a missing girl.
  A radio blares news of a Coalition victory, and someone smashes it.
  A funeral procession passes, the dead in their armour.
  A child is lost, and the parents are frantic.
  A juggler performs tricks with live grenades.
  A shopkeeper chases a thief who is faster than any human.
  A band plays pre-Rifts music on scavenged instruments.
  A figure in a trench coat asks if the party wants to earn some credits.
  A robot horse throws its rider in the square.
  A crowd watches an arena fight on a salvaged screen.
  A water truck overturns, and everyone rushes to fill buckets.
  A burst of static on every radio carries a strange voice.
  A religious procession blocks the road.
  A dragon's shadow passes over, and the whole street falls silent.
`);

// What Rifts adds to the overview: one line from each, drawn after the rest
// of the overview so a Palladium Fantasy city, which has none, is unchanged.
export const TECH_LEVELS = lines(`
  pre-Rifts ruins with working lights in a dozen buildings
  steam and diesel, with a few prized energy weapons
  modern: Northern Gun gear on every shelf
  high tech, with fusion power and hover traffic on every street
  Techno-Wizard devices everywhere, and very little that plugs in
  a strange mix of horses and hover bikes
  pre-Rifts machines kept running by stubbornness and spare parts
  scavenged gear, repaired a hundred times
  clean and modern, with a Coalition-style power grid
  frontier tech: solar panels, wind pumps and E-Clip chargers
  alien tech, traded through a rift and poorly understood
  high tech behind the walls, stone age outside them
  a working pre-Rifts computer network that still runs the town
  bionics everywhere; half the town has at least one implant
  low tech by choice, with a ban on robots
  cutting edge, thanks to a Northern Gun contract
  hand-built generators and wiring strung between rooftops
  Triax imports, expensive and reliable
  magic in place of machines: ley-lamps and enchanted pumps
  military surplus, all of it older than the people using it
  a factory town that makes its own tools and its own guns
  a single fusion plant, rationed by street
  scrap robots doing the heavy lifting
  nothing that could not be fixed with a hammer
  crystal devices from a Techno-Wizard lodge, and they hum
  pre-Rifts medical machines in the clinic and nowhere else
  hover tech; half the town floats a metre above the swamp
  radio and telegraph, and no better
  a satellite link to somewhere, though no one knows where
  modern, but every device is locked by a password only the mayor knows
  solar farms and battery walls
  water-powered mills and old electric lines
  prototypes from a laboratory that should not exist
  second-hand everything, from the scrap trains
  modern weapons, medieval sanitation
  bionics outlawed; body armour required
  gear supplied by a nearby Coalition base, at a price
  goods traded from the Splugorth, and everyone knows it
  alien biotechnology growing through the walls
  primitive, but the militia has one suit of power armour
  high tech for the rich, and candles for everyone else
  surprisingly advanced, for a reason nobody explains
`);

export const COALITION = lines(`
  none - the Coalition has never come this far
  a patrol passes through once a month
  a small Coalition outpost just outside the walls
  an embassy, with a flag and very polite guards
  a garrison, with Dog Boy kennels and a curfew
  occupied: the Coalition runs everything that matters
  hated; the last patrol that came did not leave
  a recruiting office that pays well and asks nothing
  spies, everyone assumes, but no one in uniform
  a treaty that keeps them out, as long as the town sells them food
  a supply depot, heavily guarded
  a former Coalition base, abandoned and looted
  a Coalition patrol has been missing here for a month
  sympathisers on the council, loudly patriotic
  a community of Coalition deserters that fears being found
  skirmishes with Coalition scouts every summer
  a Coalition airship passes overhead each week
  a Coalition-backed militia that reports to Chi-Town
  a Coalition bounty on half the town's residents
  none, though a Coalition robot was found in the river last spring
  a Coalition hospital, which treats humans only
  a propaganda radio station broadcasting from the hill
  a Coalition tax collector who comes with an escort
  a single Coalition officer, who seems to have gone native
  a Coalition prison camp, two days' ride away
  a truce: they stay on their side of the river
  a Coalition-issued charter on the town hall wall
  a statue of the Emperor, often defaced
  a Coalition checkpoint on the only road in
  a Coalition-built power plant, the town's lifeline
  a destroyed Coalition base, its wreckage used for walls
  Coalition-backed D-Bee hunters, paid by the head
  an underground railroad hiding D-Bees from Coalition eyes
  Coalition training exercises in the badlands nearby
  a Coalition deserter running the militia
  a Coalition surveyor mapping the town's defences
  rumours of a Coalition spy on the council
  the Coalition claims the town, but has never visited
  a Coalition officer who wants to defect
  a Coalition-built road running all the way to Chi-Town
  a Coalition inspection due soon, and the whole town is nervous
  Coalition war veterans who live here and remember
`);

export const LEY_LINES = lines(`
  none nearby; magic is rare and weak here
  a faint line runs under the market, and spells come easier there
  a strong line runs straight down Main Street
  a nexus sits at the centre of town, and the town was built around it
  two lines cross just outside the walls, and the crossing is guarded
  a line runs along the river, which glows on stormy nights
  an erratic line that shifts every few years
  a ley line storm hits the town every spring
  a dormant nexus, which the Techno-Wizards want to wake
  a line that flares every full moon, bringing strange visitors
  a dead line; the magic drained out years ago
  a line powers the town's force-field wall
  a nexus under the old cathedral, sealed with wards
  a line runs through the arena, making every fight wilder
  a nexus that opens a rift once a decade
  three lines meet on the hill, and nothing grows there
  a line guarded by an order of Cyber-Knights
  a line the Coalition wants mapped
  a line tapped by a generator for the whole town's power
  a line a dragon has claimed as its own
  a nexus with a standing stone that hums
  a line through a ruined pre-Rifts power station
  a line cuts through the graveyard, and the dead stir
  a line nobody can see but every psychic can feel
  a line the local shamans hold sacred
  a line that makes machines fail near it
  a line along the old highway, marked by blue fires
  a nexus sealed by the town's founder, at great cost
  a line through the farms, making crops grow strangely
  a ley line walker lives where two lines meet
  a line that moved closer to town after an earthquake
  a line that sometimes brings creatures through
  a small nexus under a well, and the water is magic
  a line the Techno-Wizards use to charge crystals
  a line the Pure Blood Society wants destroyed
  a line that pulses in time with a heartbeat
  a line runs under the militia barracks
  a line the town has never found, though it knows the line is there
  a nexus that draws pilgrims from three states
  a line that bends around the town, as if avoiding it
  a nexus overrun with monsters from the last rift
  a line that makes dreams very vivid
`);

export const OVERVIEW_EXTRAS = [
  { key: 'tech', label: 'Tech level', lines: TECH_LEVELS },
  { key: 'coalition', label: 'Coalition presence', lines: COALITION },
  { key: 'ley', label: 'Ley lines', lines: LEY_LINES },
];

// Race-tied lines, keyed by the catalog's Rifts R.C.C. ids. Quirks only: a
// race-tied shop needs a stock rule the Codex can fill six rows deep, and none
// of these races has one yet.
export const RACE_LINES = {
  'dragon-hatchling': { quirks: ['A young dragon lives in the old water tower, and the town pretends it is a pet.'], shops: [] },
  gargoyle: { quirks: ['A gargoyle clan roosts on the ruins at the edge of town, under a wary truce.'], shops: [] },
  kreeghor: { quirks: ['A Kreeghor exile runs the town\'s fighting school, and no one asks why.'], shops: [] },
  'lyn-srial': { quirks: ['The Lyn-Srial fly the town\'s mail and messages, for a fee.'], shops: [] },
  noro: { quirks: ['The Noro keep a quiet shrine where travellers may rest.'], shops: [] },
  'psi-pony': { quirks: ['A herd of Psi-Ponies grazes on the common, and nobody tries to ride one twice.'], shops: [] },
  'norse-giant': { quirks: ['A giant works the town gate, and lifts it by hand.'], shops: [] },
};

// A city's own name when no pool supplies one: a prefix and a suffix.
export const CITY_NAME = {
  pre: lines(`
    Ash\nBlast\nBolt\nBrass\nCinder\nCopper\nDust\nEcho\nEmber\nFlint\nForge\nFree\nGlow\nGrit\nHaven\nHollow
    Iron\nJunk\nLast\nLey\nNew\nNorth\nOld\nRail\nRift\nRust\nSalt\nScrap\nShield\nSilver\nSpark\nSteel\nStone
    Storm\nSun\nTin\nVolt\nWall\nWatch\nWild\nWire\nWreck`),
  suf: lines(`
    bridge\nburg\ncrossing\ndale\ndepot\nfall\nfield\nford\nfort\ngate\nhaven\nhill\nhold\nholm\njunction
    landing\nmark\nmill\nmoor\nmouth\npoint\nport\npost\nreach\nridge\nrock\nrun\nspring\nstation\nstead
    stop\ntown\nvale\nville\nwall\nwatch\nwater\nwell\nwick\nworks\nyard\nton`),
};

// Which people theme names each race, when no AI pool is in play. A race not
// listed takes the setting's default.
export const RACE_NAME_THEMES = {
  human: 'rifts-frontier', kreeghor: 'rifts-atlantean', 'machine-people': 'rifts-street',
};
export const DEFAULT_PEOPLE_THEME = 'rifts-frontier';

// "Roll stats": the O.C.C. an NPC's role maps to. In Rifts a human rolls as
// that O.C.C. alone, and a non-human as their R.C.C. alone (RACE_TAKES_OCC).
export const ROLE_OCC = {
  bartender: 'vagabond', gunsmith: 'operator', 'militia sergeant': 'merc-soldier', preacher: 'preacher',
  merchant: 'vagabond', salvager: 'operator', farmer: 'vagabond', thief: 'city-rat', scholar: 'rogue-scholar',
  medic: 'body-fixer', mercenary: 'merc-soldier', 'town elder': 'rogue-scholar', beggar: 'vagabond',
  musician: 'vagabond', moneylender: 'professional-gambler', mechanic: 'operator', 'stable-hand': 'cowboy',
  herbalist: 'rogue-scientist', 'ferry pilot': 'vagabond', 'tax collector': 'rogue-scholar',
  gravedigger: 'vagabond', 'water engineer': 'operator', 'bounty hunter': 'bounty-hunter', tailor: 'vagabond',
  'river trader': 'vagabond', 'radio operator': 'operator', 'fortune-teller': 'mystic',
  'retired adventurer': 'freelancer', 'gate guard': 'merc-soldier', smuggler: 'city-rat', cook: 'vagabond',
  brewer: 'vagabond', builder: 'operator', 'arena fighter': 'juicer-gladiator', judge: 'rogue-scholar',
  'hedge mage': 'ley-line-walker', pilgrim: 'vagabond', 'rat-catcher': 'vagabond',
  'street-lamp keeper': 'vagabond', 'junk dealer': 'operator', 'caravan scout': 'wilderness-scout',
  schoolteacher: 'rogue-scholar',
};
// A shop owner keeps shop; Rifts has no merchant O.C.C., and the Vagabond is
// its catch-all.
export const OWNER_OCC = 'vagabond';
export const PLACES_THEME = 'rifts-places';

// Shop inventories: rules over the Codex's Rifts gear rows, as for Palladium
// Fantasy. Keyed by the shop type's label.
export const SHOP_STOCK = {
  Bar: [{ category: 'gear', name: 'provisions|rations|cigarette|lighter|salt|musical instrument|sunglasses|canteen' }],
  'Gun shop': [{ category: 'weapon', not: 'robot|giant|torpedo|depth charge|harpoon:|rune|boom gun|glitter boy' },
    { category: 'gear', name: 'e-clip|ammo|clips|rounds|holster|speed loader|bandoleer' }],
  'Armour shop': [{ category: 'armor', not: 'barding|force field|field\\)|odin|valkyrie|pantheon|dragon|kreeghor|gargoyle|worms' }],
  'Body-chop-shop': [{ category: 'cybernetics' }],
  'General store': [{ category: 'gear', name: 'backpack|knapsack|sack|duffle|rope|cord|canteen|flashlight|tent|sleeping bag|compass|tool kit|duct tape|poncho|saddlebags|luggage|flare' }],
  'Techno-Wizard shop': [{ category: 'weapon', name: '^tw |tw-|techno-wizard|crystal' }, { category: 'gear', name: 'crystal|^tw ' }],
  'Vehicle lot': [{ category: 'vehicle', not: 'navy|battleship|carrier|tanker|parasite|krikton|freighter|glitter boy|samas|battle saint|coast guard|power armor' }],
  'Medical clinic': [{ category: 'gear', name: 'medical|med kit|surgical|scalpel|suture|stethoscope|hypodermic|band-aids|irmss|rmk|rau|rsu|protein healing|bio-' }],
  'Electronics shop': [{ category: 'gear', name: 'communicator|radio|computer|radar|binoculars|camera|recorder|translator|scrambler|jammer|sensor|detector|geiger|dosimeter|microphone|tracer bug|laser distancer' }],
  Outfitter: [{ category: 'gear', name: 'clothing|fatigues|boots|gloves|goggles|sunglasses|poncho|cloak|robe|jumpsuit|uniform|gas mask|air filter|helmet' }],
  'Magic shop': [{ category: 'magic' }],
};
