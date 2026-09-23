// The name generator's word lists - every theme it can draw from. The engine
// is shared/js/namegen.js; nothing here runs.
//
// ALL OF THIS IS WRITTEN FOR THIS FILE. None of it is copied from a sourcebook
// or an OCR cache: a book's own name lists are its text, and book text is never
// committed here. Common real-world given names and surnames are not anybody's
// text and are used freely; everything that sounds like a setting - the houses,
// the packs, the callsigns, the taverns - was made up for this file.
//
// Shape of a theme:
//   id, label, blurb      what the picker shows
//   games                 'rifts' | 'palladium-fantasy' | 'nightbane' | 'generic'
//                         (a generic theme is offered to every game)
//   cultures              free tags the picker filters on
//   kinds.person          { lists, shapes: { shape: [pattern...] }, defaultShape }
//   kinds.<place kind>    { lists, patterns: [pattern...] }
// A pattern is text with {slot}s. A slot is a word list; a gendered slot is
// { masc, fem, neutral }; a JOIN glues syllable lists into one word - the
// syllable rule, with the seam tidied by namegen.js tidy().
//
// Size is the point of these lists. The City Creator plan's bar is 200 or more
// name parts per culture and 40 or more entries per list, because too few is
// what makes every city feel the same. The smoke check reads that bar back out
// of these lists rather than trusting this comment.

const w = (s) => s.trim().split(/\s+/);
const p = (s) => s.split('|').map((x) => x.trim()).filter(Boolean);
const join = (...parts) => ({ join: parts });

// ═══════════════════════════ RIFTS ═══════════════════════════

const riftsFrontier = {
  id: 'rifts-frontier', label: 'Frontier human', games: ['rifts'], cultures: ['human', 'frontier'],
  blurb: 'Homesteaders, drifters and \'Burb folk of the North American wilds.',
  kinds: { person: {
    lists: {
      given: {
        masc: w(`Abel Amos Beck Boone Brody Cade Caleb Cash Cole Colt Dallas Dawson Deke Eli Emmett Ezra
          Flint Gage Gideon Grady Hank Harlan Hollis Ike Jace Jed Jericho Jesse Judd Lane Levi Luke Mack
          Moses Nash Obadiah Otis Pike Rafe Reno Rhett Rook Sawyer Silas Tate Tobias Tucker Wade Walker
          Wyatt Zeke Ambrose Clay Duncan Garrett Hobart Lyle`),
        fem: w(`Abigail Addie Annie Birdie Bess Callie Cassidy Clementine Cora Daisy Delphine Dixie Dora
          Eden Ellie Esther Etta Fern Georgia Grace Hattie Hazel Ida Ivy Jolene June Laurel Lila Lottie
          Lucy Mabel Maggie Mae Marigold Maisie Nell Opal Pearl Prudence Reba Rosa Ruby Sadie Savannah
          Tess Trixie Violet Willa Winnie Zora Adeline Belle Josie Leona Myrtle`),
        neutral: w(`Ash Bailey Blair Brook Cameron Casey Dakota Drew Ellis Emery Finley Gray Harper Hayden
          Jordan Kendall Kit Lee Morgan Parker Quinn Reese Riley River Rowan Sage Shay Sky Taylor Wren`),
      },
      family: w(`Abernathy Ashby Bale Barlow Birch Blackwood Boyd Brannock Breck Burke Cage Calloway Carver
        Colter Crane Cutter Dade Dalton Decker Drummond Dunmore Eakins Estes Farris Fenn Frame Galt
        Garrity Gault Graves Hackett Halloran Harlow Haskett Holt Hooper Hux Ingram Jarrett Keel Kincaid
        Ladd Lassiter Loomis Maddox Marsh McCrae Mercer Merritt Nolan Oakes Pardee Pruitt Quarles Radley
        Ransom Reddick Rourke Rucker Sayer Scully Slade Sloane Stroud Sutter Tagg Teague Thorne Tillery
        Vance Varga Voss Wardell Weems Whitlock Yarrow Yates Cobb Dorsey Emmons Fitch`),
      epithet: p(`the Drifter|Two-Guns|One-Eye|Deadeye|the Wrangler|Ironjaw|the Undertaker|Quickdraw|
        the Salvager|Longrider|the Preacher|Dustwalker|the Tinker|Scattergun|the Widowmaker|Rustbucket|
        the Gambler|Ridgeback|the Mender|Stormchaser|Lucky|the Lawless|Burnside|the Ranger|Coldiron|
        the Stray|Blackpowder|the Outrider|Railspike|the Mule|Hardcase|the Surveyor|Brushfire|the Ghost|
        Tallboy|the Pilgrim|Sidewinder|the Quiet|Tumbleweed|Old Iron|the Prospector`),
    },
    shapes: {
      given: ['{given}'],
      'given+family': ['{given} {family}'],
      epithet: ['{given} {epithet}', '{given} {family} {epithet}'],
    },
    defaultShape: 'given+family',
  } },
};

const riftsCoalition = {
  id: 'rifts-coalition', label: 'Coalition rank and callsign', games: ['rifts'],
  cultures: ['human', 'military', 'coalition'],
  blurb: 'Soldiers of the Coalition States: a rank, a surname and the callsign the squad gave them.',
  kinds: { person: {
    lists: {
      given: {
        masc: w(`Adler Anton Axel Brandt Bruno Conrad Dieter Dirk Emil Erik Ernst Felix Franz Gunnar Hagen
          Hans Horst Ivo Jens Joachim Jurgen Kai Karl Klaus Kurt Lars Lorenz Lothar Ludwig Magnus Nils Olaf
          Oskar Otto Rainer Reinhold Rolf Rudi Sepp Stefan Sven Theo Ulrich Viktor Walther Werner Garrick
          Brock Dane Holt`),
        fem: w(`Adela Anja Astrid Berta Brigitte Carla Dagmar Elke Elsa Erika Frieda Gerda Greta Hanna Heidi
          Helga Ilse Inge Irma Jutta Karin Katja Klara Lena Liesl Lotte Margit Marta Monika Nadia Petra
          Renate Rita Sabine Silke Sonja Tanja Thea Ulla Uta Vera Wanda Wilma Brenna Kerstin`),
        neutral: w(`Alex Andy Chris Dana Frankie Gale Jamie Jody Kerry Lou Nicky Pat Robin Sam Terry Toni Val
          Charlie Jesse Rory`),
      },
      family: w(`Albrecht Arnholt Bauer Becker Brandauer Brenner Cardell Dorn Drexler Eckert Falk Fischer
        Frost Geller Graff Gruber Hahn Harker Hartmann Heller Hess Hollister Holtz Jaeger Kane Kessler Kline
        Koch Kraus Kruger Lang Lindner Lutz Mahler Mann Marek Mauer Moser Neumann Olbrich Pfeiffer Prentiss
        Rausch Reiter Ritter Sauer Schaller Schenk Schroder Seidel Stahl Steiner Stoltz Strand Thiel Trask
        Ulbrich Vogel Voigt Wagner Walz Weber Wendt Winter Wolff Zander Ziegler Zimmer Dressler Kohler`),
      rank: p(`Private|Private First Class|Corporal|Sergeant|Staff Sergeant|Master Sergeant|Specialist|
        Lieutenant|Captain|Major|Colonel|Commander`),
      callsign: w(`Deadbolt Hammer Ghost Anvil Viper Spade Torch Warden Rivet Hatchet Nail Crowbar Lockjaw
        Tinman Bulldog Jackal Rattler Spook Sparrow Hawk Kestrel Bishop Deacon Shiv Gravel Cinder Ember
        Frostbite Blackjack Skullcap Echo Static Longshot Buckshot Tracer Striker Halo Vulture Cobalt
        Graphite Stonewall Bayonet Tripwire Flak Mortar Sabre Lancer Grizzly Whisper Razor Ramrod Payload
        Chisel Deadlift Brass Tombstone`),
    },
    shapes: {
      given: ['{given}'],
      'given+family': ['{given} {family}'],
      callsign: ['{rank} {family} "{callsign}"'],
    },
    defaultShape: 'callsign',
  } },
};

const riftsStreet = {
  id: 'rifts-street', label: 'Juicer and street callsign', games: ['rifts'],
  cultures: ['human', 'street', 'juicer'],
  blurb: 'City Rats, Juicers and Crazies: the name on the street, and the one their mother used.',
  kinds: { person: {
    lists: {
      given: {
        masc: w(`Ace Benny Bo Carl Danny Eddie Frank Gus Hector Joey Johnny Lenny Manny Marco Mickey Nico
          Rico Ronnie Sal Sonny Tommy Vic Vinny Wes Zack Andre Dante Duke Floyd Ivan Jax Leon Lou Mitch Omar
          Paulo Ray Roy Ty Hugo`),
        fem: w(`Angie Bella Bonnie Candy Carmen Cherry Dee Dina Gina Jade Jess Jo Kat Lexi Lola Lulu Maddie
          Mona Nina Roxy Sasha Sheena Tina Trish Vicky Yolanda Zoe Bree Coco Dolly Fran Gigi Izzy Kiki Liz
          Mimi Pam Rita Tammy Lana`),
        neutral: w(`Bix Cass Dex Fitz Jay Jules Lux Max Nix Pip Rae Rin Sid Taz Vee Zed Zig Frankie Remy
          Lonnie`),
      },
      family: w(`Kowalski Moreno Russo Vega Diaz Novak Brennan Costa Delgado Fontaine Gallo Hanley Ibarra
        Janssen Keegan Lombardi Marsh Navarro O'Leary Pace Quintero Reyes Sato Toomey Ulrich Varela Webb
        Yoon Zale Abbott Burkett Cruz Doyle Esposito Flynn Grady Hayes Irwin Jett Kerr`),
      callsign: w(`Doc Tiny Slick Moxie Ricochet Juice Hotwire Stitch Twitch Pistol Dynamo Fuse Detour Jinx
        Sprocket Mayday Kickstart Overdrive Afterburn Riot Havoc Ruckus Mojo Blitz Zipper Scooter Cricket
        Pixie Tango Rocket Diesel Octane Piston Trigger Boomer Buzzsaw Chainsaw Wrench Gizmo Hazard
        Frenzy Mercy Nova Pulse Rebel Rogue Sassy Tex Tank Torque Vapor Zero Zippo Sparkplug Redline`),
      cpre: w(`Razor Chrome Steel Neon Nitro Rust Iron Grave Blood Bone Hex Volt Turbo Crash Shock Burn Smoke
        Ash Slag Scrap Rad Glitch Flash Grim Snake Wire Blade Skull Spike Dead Mad Quick Night Red Black Hot
        Cold Hard Wild Bright`),
      csuf: w(`back jack dog head fist tooth bite spark line rider runner lock hound fang eye neck jaw heart
        hand foot gut shot cap crank drive step kick bolt switch rat cat wolf bird snap trip deck cutter
        grin tail`),
    },
    shapes: {
      given: ['{given}'],
      'given+family': ['{given} {family}'],
      callsign: ['{callsign}', '{cpre}{csuf}'],
    },
    defaultShape: 'callsign',
  } },
};

const riftsDogBoy = {
  id: 'rifts-dog-boy', label: 'Dog Boy', games: ['rifts'], cultures: ['canine', 'mutant', 'coalition'],
  blurb: 'Mutant canines of the Coalition\'s kennels: a short name a handler can shout, and a nickname earned.',
  kinds: { person: {
    lists: {
      given: {
        masc: w(`Rex Duke Rocky Buster Bruno Tank Scout Shep Boomer Chief Major Sarge Bandit Blue Rusty Hunter
          Bear Brutus Gunner Hank Jake Kodiak Moose Ringo Rufus Sam Titan Tucker Zeus Barkley Butch Chester
          Dozer Fritz Bosco Otto Samson Jasper Thor Axel`),
        fem: w(`Bella Daisy Lady Luna Molly Sadie Roxy Ginger Honey Pepper Penny Rosie Sasha Trixie Willow
          Abby Bonnie Cleo Dixie Duchess Freckles Gracie Hazel Juno Lulu Maggie Missy Nala Nellie Pixie
          Queenie Ruby Sheba Skye Sugar Tess Tilly Xena Zelda Poppy`),
        neutral: w(`Ash Biscuit Bolt Boots Chance Copper Dusty Echo Flash Jinx Lucky Nugget Patch Pip Rascal
          Scrappy Shadow Smokey Socks Tag Taffy Tip Ziggy Ranger Tracker Scout-Two
          Sparky Dodger Tinker Rook Gravel Pepperjack Mudlark Kettle Trooper Sprocket Flint Cinder Pickles
          Nibbles Tumble Wags Hopper Rivet Gizmo Dash Moxie Radar Nacho Bullet Sergeant-Two`),
      },
      epithet: w(`Longnose Mudpaw Quickear Greyback Brokentail Sharpnose Two-Tone Bigfoot Redcoat Blackmask
        Whitesock Stumpy Silvermuzzle Ironjaw Longleg Hotnose Burr Floppy-Ear Scarface Nosewise
        Barrelchest Stubtail Ragear Spotback Tanpaw Dusktail Frostmuzzle Lopear Nightcoat Rustcoat
        Quicktrack Steadynose Hardpaw Keeneye Whisperstep Braveheart Loudmouth Slowpoke Brindle Pathnose
        Chewtoy Muddyboots Nosedive Tailwag Bonecrusher Gatekeeper Sniffer Halfear Coldnose Longhowl
        Deadeye Stormbark Dustcoat Hardcase Crookedtail Softpaw Firebrand Longwatch Rattail Scentmaster
        Tripwire Ashcoat Nightnose Bristleback Growler Trailblazer Lastbark Siltpaw Duskhound Kennelborn`),
    },
    shapes: {
      given: ['{given}'],
      epithet: ['{given} {epithet}'],
    },
    defaultShape: 'given',
  } },
};

const atlPre = w(`Aer Kal Vor Zeth Mal Sar Tor Xan Dra Vel Ith Oru Kha Zor Bel Nex Quor Thal Ul Yss Ar Ceph
  Dhar Hes Jor Lyr Mor Nar Phae Rha Syl Tyr Vash Zar Ek Gor`);
const riftsAtlantean = {
  id: 'rifts-atlantean', label: 'Splugorth and Atlantean nobility', games: ['rifts'],
  cultures: ['atlantean', 'alien', 'noble'],
  blurb: 'The courts of Atlantis: lords, slavers and their favoured, named in old and alien syllables.',
  kinds: { person: {
    lists: {
      given: {
        masc: join(atlPre, w('ath eon ius or ax oth arn ek ion uul ar esh ovar ux idon orak azz eth im ekhar')),
        fem: join(atlPre, w('a ia ys ethra ine ael isse ora yne ae esha iva ara ielle one ith aya ena ysse ahra')),
        neutral: join(atlPre, w('is en al yr ane el iss orin u ith')),
      },
      house: w(`Veshtar Olumar Kethren Zarimoth Aelvanis Draxen Ithuril Morvath Quelloran Sethrak Tyrvane
        Ulthaar Vaelcor Xandrith Yssembar Zothrenn Belmaros Cephiran Dharvessa Hesperoth Jorvaine Lyrrath
        Maelzor Naxxurin Phaedrossa Rhaskell Sylvarix Tyrreth Vashkaal Zarathine Ekkoran Gorvesh Khaldros
        Oruvane Quorrith Thalissar Uldraxis Velthorne Xenmarok Nexuvar
        Aurvesk Brelloth Cazzarin Dhuulmar Esserak Fenzhaal Galvorith Hurrasca Imvessa Jhaeloth Korrazin
        Lethvarn Mizzuran Nuulveth Othrakis Pelzarim Qethuula Rovaskin Sarrakoth Thuvessa Uzzarath
        Vyrrandel Wexxoran Xhelvari Yzzorath Zhaelmir`),
      epithet: p(`the Many-Eyed|the Twice-Crowned|the Slave-Taker|Keeper of the Tenth Gate|the Unblinking|
        the Pale Hand|the Tidebound|of the Ashen Stair|the Gilded|the Serpent-Tongued|the Coin-Eater|
        the Collector|of the Drowned Market|the Bone-Buyer|the Patient|the Unforgiving|Warden of Chains|
        the Bright Tyrant|of the Glass Towers|the Beloved of the Lord|the Hungry|Mouth of the Court|
        the Eyeless|the Ever-Watchful|the Silk-Handed|of the Black Wharf|the Deathless|the Tithe-Taker|
        the Branded|the Radiant|the Horned|of the Seventh Circle|the Dreadful|Herald of the Deep|
        the Scale-Bearer|the Bargainer|the Iron Voice|the Coldborn|the Last Heir|the Sorrowless|
        the Salt-Crowned|Lord of Lesser Tides|the Chain-Maker|of the Sunken Arena|the Twice-Sold|
        the Mask-Wearer|the Glass-Eyed|Speaker for the Deep|the Stone-Hearted|of the Weeping Pillars|
        the Debt-Keeper|the Emberborn|the Wave-Breaker|of the Hollow Throne|the Unbought|
        the Pearl-Handed|the Nameless Heir|the Lantern of the Court|of the Nine Moorings|the Tide-Caller`),
    },
    shapes: {
      given: ['{given}'],
      'given+family': ['{given} of House {house}'],
      epithet: ['{given} {epithet}', '{given} of House {house}, {epithet}'],
    },
    defaultShape: 'given+family',
  } },
};

const sovMasc = w(`Andreev Belov Bogdanov Volkov Vorontsov Gromov Denisov Dudin Egorov Zaitsev Zorin Ivanov
  Kozlov Komarov Krylov Kuznetsov Lebedev Makarov Medvedev Morozov Nikitin Novikov Orlov Pavlov Petrov
  Popov Rybakov Savin Semenov Sokolov Stepanov Tarasov Titov Fedorov Frolov Kharitonov Chernov Sharov
  Shubin Yakovlev Baranov Gusev Karpov Lazarev Markov Osipov Rodin Sidorov Utkin Vinogradov`);
const riftsSovietski = {
  id: 'rifts-sovietski', label: 'Sovietski and Mystic Russia', games: ['rifts'],
  cultures: ['human', 'slavic', 'russian'],
  blurb: 'Warlord camps, Sovietski towns and the villages of the haunted Russian forests.',
  kinds: { person: {
    lists: {
      given: {
        masc: w(`Aleksei Anatoly Andrei Arkady Bogdan Boris Dmitri Evgeny Fyodor Gennady Gleb Grigori Igor
          Ilya Ivan Kirill Konstantin Lev Leonid Maksim Matvei Mikhail Nikolai Oleg Pavel Pyotr Roman
          Ruslan Semyon Sergei Stanislav Stepan Taras Timur Vadim Valentin Vasily Viktor Vladimir Yaroslav
          Yuri Zakhar`),
        fem: w(`Alina Anastasia Anya Daria Ekaterina Elena Galina Inna Irina Katya Kira Ksenia Larisa Lidia
          Lyudmila Marina Milena Nadia Natalya Nina Oksana Olga Polina Raisa Sofia Svetlana Tamara Tatiana
          Ulyana Valentina Varvara Vera Yelena Yulia Zhanna Zoya Alyona Agata Dunya Masha`),
        neutral: w(`Sasha Zhenya Valya Shura Slava Nika Kolya Tosha Lyosha Misha Vanya Petya`),
      },
      family: {
        masc: sovMasc,
        fem: sovMasc.map((s) => s + 'a'),
        neutral: w(`Bondar Kovalenko Shevchuk Moroz Tkach Kravets Lysenko Melnyk Savchenko Hrytsenko Oliynyk
          Rudenko Zhuk Koval Polishchuk Kovalchuk Marchenko Boyko Tkachenko Kushnir Honchar Didenko Fedoruk
          Yarema Pasichnyk`),
      },
      epithet: p(`the Bear|Iron Hand|the Wolf-Killer|the Quiet|of the Red Snow|the Smith|Old Winter|
        the Long Walker|the Ferryman|Frostbeard|the Blind|the Tsar's Dog|of the Burnt Village|the Tall|
        the Hermit|Birch-Bark|the Hunter|Two-Rivers|the Crow|the Witch-Finder|Stove-Warm|the Oathbreaker|
        the Pale|Axe-Hand|the Cossack|the Deserter|Cold-Eyes|the Lucky|Ash-Face|the Bell-Ringer|
        the Borscht-Maker|the Grave-Watcher|Rimefoot|the Soldier|Nine-Lives|the Saint|the Sinner|
        the Horseless|the Boatman|of the Black Pines`),
    },
    shapes: {
      given: ['{given}'],
      'given+family': ['{given} {family}'],
      epithet: ['{given} {epithet}'],
    },
    defaultShape: 'given+family',
  } },
};

const riftsPlaces = {
  id: 'rifts-places', label: 'Rifts Earth places and gangs', games: ['rifts'],
  cultures: ['frontier', 'post-apocalyptic', 'burbs'],
  blurb: 'Bars, borg and weapon shops, airships and submarines, \'Burb districts and gangs.',
  kinds: {
    tavern: {
      lists: {
        adj: w(`Rusty Radioactive Broken Busted Burning Glowing Crooked Last Lucky Dead Drowned Scorched Hollow
          Chrome Cracked Melted Bent Blown Iron Loaded Leaky Howling Sleeping Wired Screaming Singing
          Stolen Bloody Dusty Sunken Twisted Rotten Lonely Crazy Juiced Fried Frozen Laughing Cursed
          Blind`),
        noun: w(`Rifter Skull Coyote Buzzard Mule Piston Reactor Rivet Boot Gauntlet Canteen
          Wrench Spur Bullet Shell Tank Barrel Jukebox Crater Nomad Scav Drifter Deadboy Borg
          Juicer Longhorn Rattler Scorpion Vulture Trough Wagon Hovercycle Cannon Bunker Silo Satellite
          Well`).concat(p('Glitter Boy|Ley Line|Plasma Torch|Robot Head|Power Cell|Ley Stone')),
        owner: p(`Big Hank|Mama Lu|One-Eye Jo|Crazy Earl|Doc Riggs|Old Mags|Tex|Sweet Sally|Rusty Pete|
          Granny Voss|Slick Willie|Deadeye Dana|Kat|Ma Tillery|Two-Gun Tommy|Honest Abe|Short Stack|
          Lucky Lou|Burn|Sister Ruth|Iron Mike|Dutch|Juicy Lucy|Cap'n Hollis|Stubs|Wanda|Red|Gramps|
          Skeeter|Blue|Hot Rod|Mad Maxine|Boone|Nails|Fat Sam|Dusty|Ruby Jane|Cooter|Pops|Frankie Two-Times`),
        house: w(`Place Saloon Bar Tap Den Pit Hole Joint Roadhouse Cantina Watering-Hole Dive Lounge Hideout
          Shack`),
        drink: p(`Rotgut|Moonshine|Glowjuice|Tanglefoot|Snakebite|Hooch|Fuel|Swill|Whiskey|Brew|Mash|Nitro|
          Rustwater|Sludge|Jolt|Bitterroot|Coldfire|Dustbowl|Firewater|Sidecar`),
      },
      patterns: ['The {adj} {noun}', '{owner}\'s {house}', 'The {drink} {house}'],
    },
    shop: {
      lists: {
        owner: p(`Krieger|Dalton|Mendez|Voss|Okafor|Brennan|Tully|Harkness|Kowal|Rourke|Lindqvist|Salazar|
          Pike|Hendrix|Nakamura|Duarte|Gruber|Coyle|Madsen|Oyelaran|Fitch|Petrosyan|Bauer|Castellanos|
          Holloway|Janek|Reyes|Sorensen|Tran|Whitcombe|Abara|Bristow|Crane|Delacroix|Eckhart|Faraday|
          Gantz|Hollister|Ivers|Jurado`),
        trade: p(`Cybernetics|Borg Works|Arms & Armor|Guns & Ammo|Salvage|Power Armor Repair|Chop Shop|
          Bionics Clinic|E-Clip Recharge|Robot Parts|Body Chop-Shop|Weapon Smithy|Tech Exchange|
          Hover Repair|Armory|Parts & Pieces|Scrap Yard|Implant Parlour|Techno-Wizardry|Energy Weapons|
          Surplus|Munitions|Vehicle Works|Rail Gun Repair|Sensor Shop|Machine Shop|Chrome & Bone|
          Gear Exchange|Pawn & Loan|Field Medic|Juicer Clinic|Mag Works|Plasma Works|Laser Shop|
          Bot Doc|Mech Garage|Fuel & Cells|Mercenary Supply|Salvage & Trade|Rebuild Shop`),
        brand: p(`Dead Reckoning|Iron Horse|Black Market|Last Chance|Rust Belt|Hard Luck|High Voltage|
          Second Skin|Burned Bridge|Cold Steel|Red Line|New Metal|Scrap Heap|Full Metal|Short Circuit|
          Top Gun|Straight Shot|Zero Point|Heavy Metal|True Aim|Quick Fix|Borg Heaven|Titan|Lucky Strike|
          Ground Zero|Blue Spark|Silver Bullet|Kill Switch|Hot Wire|Scatter|Steel Rain|Deep Six|
          Night Owl|Gold Tooth|Dust Devil|Longshot|Rattletrap|Warhorse|Sparkplug|Brass Knuckle`),
      },
      patterns: ['{owner}\'s {trade}', '{owner} {trade}'],
    },
    ship: {
      lists: {
        sadj: w(`Iron Silver Crimson Black Silent Restless Lucky Stubborn Swift Burning Rusted Steel Gray
          Midnight Thunder Storm Dawn Dusk Wandering Vengeful Hungry Patient Drowned Screaming Laughing
          Northern Deep Cold Last Broken Proud Savage Pale Free Wild Hollow Fearless Stolen Blind Mighty`),
        snoun: w(`Albatross Leviathan Barracuda Manta Marlin Orca Harpoon Trident Anchor Kraken Cormorant
          Gull Heron Osprey Condor Falcon Petrel Tern Moray Stingray Nautilus Narwhal Turtle Sturgeon
          Pike Walleye Gar Muskie Mako Hammerhead Grouper Dolphin Seal Walrus Otter Pelican Skua Raven
          Kite Swift`),
        sname: w(`Resolute Endurance Perseverance Tenacity Wanderlust Providence Redemption Salvation
          Liberty Defiance Vigilant Relentless Intrepid Audacity Fortitude Bravado Serendipity Gambit
          Windfall Jackpot Payday Longshot Paydirt Gumption Moxie Gallant Valiant Stalwart Reckoning
          Undertow Riptide Squall Tempest Cyclone Monsoon Maelstrom Whirlwind Downpour Thunderhead`),
      },
      patterns: ['The {sadj} {snoun}', '{sname}', '{sadj} {sname}'],
    },
    district: {
      lists: {
        bname: w(`Rust Tin Scrap Mud Ash Glow Shanty Tent Slag Cinder Brick Junk Bone Tar Lamp Chrome Dust
          Gravel Rubble Hope Dry Pipe Cable Wire Oil Salt Rat Crow Gutter Sprawl Sump Weed Wheel Coal Cog
          Bolt Tank Market Dog Mill`),
        bplace: p(`Town|Row|Flats|Hollow|Heap|Pits|Alley|End|Lane|Yard|Gulch|Stacks|Ridge|Bottoms|Corner|
          Warrens|Wall|Fields|Heights|Crossing`),
        burb: w(`Hobbs Kettle Chalmers Ridley Dunmore Pruitt Harrow Gault Morrow Fenn Vickers Barlow Sloane
          Hatch Keel Ransom Wicker Tully Mercer Crane Doyle Pike Varga Loomis Dade Hux Rook Stroud Tagg Weems
          Cobb Ladd Oakes Quarles Radley Sayer Teague Voss Yates Burke`),
      },
      patterns: ['{bname} {bplace}', '{burb} Burb', '{burb}\'s {bplace}', 'Old {bname} {bplace}'],
    },
    gang: {
      lists: {
        gadj: w(`Chrome Iron Rusty Mad Dead Burning Red Black Grinning Rabid Screaming Wild Toxic Hungry Bone
          Neon Nuclear Dirty Mean Lost Killer Crazy Savage Bloody Rotten Grim Feral Silent Broken Twisted
          Howling Bad Hollow Gutter Wicked Sick Bent Loaded Hard Wired`),
        gnoun: w(`Rats Dogs Jackals Coyotes Vultures Snakes Scorpions Wolves Skulls Knives Chains Pistons
          Sparks Rivets Burners Juicers Crazies Ghouls Ghosts Saints Sinners Reapers Rollers Riders Kings
          Queens Jokers Aces Deuces Brothers Sisters Wreckers Scavs Blades Hammers Heads Fangs Claws Stompers
          Screamers`),
        crew: p(`Boys|Girls|Crew|Posse|Mob|Gang|Pack|Clan|Syndicate|Outfit`),
      },
      patterns: ['The {gadj} {gnoun}', '{gadj} {gnoun} {crew}'],
    },
  },
};

// ═══════════════════════ PALLADIUM FANTASY ═══════════════════════

const pfWestern = {
  id: 'pf-western-empire', label: 'Western Empire', games: ['palladium-fantasy'],
  cultures: ['human', 'imperial', 'noble', 'merchant'],
  blurb: 'The old, rich and decadent Empire: Latinate given names, proud family names, a court epithet.',
  kinds: { person: {
    lists: {
      given: {
        masc: w(`Aurelan Bastor Caelvin Cassor Corvane Decimar Dorian Evandor Faustin Galvren Hesperan Iovan
          Julian Lucan Malchor Marcellin Maximor Nerevan Octavar Orsino Pellan Quintor Sabinar Septimon
          Severan Tarquil Titian Valerin Varus Vespan Aldus Belisar Cyprian Demetrios Florian Gratian
          Justinor Leontes Nicanor Philon Rufinus Stephanos Theodric Valens Xanthus Zeno Albinar Corvius
          Lucretor Aemilan`),
        fem: w(`Aelira Albina Aurelys Calpurna Cassiane Claudine Corvina Decima Domitra Evadne Faustine Flavia
          Galla Helenna Honoria Iovanna Julessa Lavinia Livana Lucilla Marcella Maxentia Octavia Oriana
          Pellina Placida Quintessa Sabina Serena Severa Sulpicia Tertia Theodora Valeria Veranna Vespera
          Viviane Zenobia Agrippina Anthea Berenice Camilla Drusilla Eudocia Fausta Irenna Justina Mirella
          Nerissa Aemilia`),
        neutral: w(`Aurel Celestin Crispin Dacian Emeris Ilian Iuvenal Lior Marin Noel Orel Pax Remy Sabin
          Silvan Solen Tamsin Tiber Valen Verin Vian Zephyr Casimir Laurent Ambrose`),
      },
      family: w(`Ambrosi Arcavi Belcastro Borvani Calvessa Cantarini Corvessi Dalvaro Damarin Everardi Falcone
        Ferrante Galvessi Gennaro Lanzavecchia Leoncavi Malvessi Marzano Montevar Morenzi Nerazzi Orsanti
        Palladore Pavessi Quaranta Rovella Savarese Serravalle Solimene Tarvisi Tavolaro Ursini Valdarno
        Varesco Vesconte Viscardi Zambrano Zanotti Aldovar Belmarin Castavel Corvaldo Dellacorte Esposar
        Fiorenzo Gallardo Ignavi Lorvesso Mancuri Octavion Pellegrin Quirinal Rastelli Sanvetti Tessaro
        Ubaldin Vastiano Zefirino Albrezzi Benvolar Candessi Dorvante Ermellini Fabbriano Gisolfi
        Iacoporo Lucenzi Marravel Novellari Olivanti Passerini Ruggeri Scaldani Terracina Valmonte
        Vittorelli Zaccaro`),
      epithet: p(`the Gilded|the Magnanimous|the Younger|the Elder|the Pious|the Silvertongued|Goldpurse|
        the Unbowed|the Hawk|the Lesser|the Scholar|the Just|the Cruel|the Bold|Twice-Exiled|the Perfumed|
        of the Violet Court|the Heir|the Bastard|the Lame|the Fair|the Patient|the Merchant-Prince|
        the Poisoner|the Ashen|the Faithless|the Magnificent|the Wary|Longspear|the Orator|the Sleepless|
        the Debtor|the Beloved|the Stern|the Last|the Architect|the Quiet|the Loyal|the Spendthrift|
        of the Amber Throne`),
    },
    shapes: {
      given: ['{given}'],
      'given+family': ['{given} {family}'],
      epithet: ['{given} {epithet}', '{given} {family} {epithet}'],
    },
    defaultShape: 'given+family',
  } },
};

const pfEastern = {
  id: 'pf-eastern-territory', label: 'Eastern Territory', games: ['palladium-fantasy'],
  cultures: ['human', 'frontier', 'rural'],
  blurb: 'Frontier towns, farms and border forts: plain given names and names that say where you are from.',
  kinds: { person: {
    lists: {
      given: {
        masc: w(`Aldwin Bertram Bran Cuthric Dunstan Edgar Eadric Fenwick Garrick Godric Hal Harwin Holt
          Ingram Jory Kenric Lathan Leofric Merrick Nyle Osric Oswin Perrin Radley Roderick Rolf Selwyn
          Stellan Tamlin Thane Tobin Ulric Wendel Wilmot Wystan Yorick Alden Anselm Barnaby Colm Everett Galen
          Hobb Jasper Kenelm Lowell Mathias Orrin Piers Wat`),
        fem: w(`Adela Aldith Aveline Beatrix Bettris Brynna Cressa Edda Elswyth Emlyn Ethra Faye Gisla Gwenith
          Hedda Hilde Idony Isolt Jessamy Kendra Leofa Linnet Maude Mildra Nessa Odila Osyth Petra Rowena
          Sabeth Sigrun Theda Ulla Wenna Wilda Wynn Yseult Alys Cicely Dulcie Ermengard Felda Goda Helewise
          Joan Lettice Mabyn Agnes Hawise Margery`),
        neutral: w(`Ash Bryn Carey Corin Dale Ellis Emery Fenn Gale Hale Kerry Lane Lark Morgan Perry Quinn Rain
          Reed Robin Rowan Sage Sidney Tam Tay West`),
      },
      family: w(`Ashdown Barrowby Blackmere Bramble Brightwater Brockhurst Carrow Coldharbour Dunhollow Elmsworth
        Fairweather Fallowfield Fenwright Frostholm Greaves Greenholt Hallorn Hartwell Hawksmoor Heathcote
        Holloway Ironside Kettleby Kingsley Langstaff Larkin Lockhart Longbarrow Marchbank Merriwether
        Millbrook Mossgrove Northcott Oakhurst Oldcastle Pennywhistle Quarrington Ravensworth Redfern Ridley
        Rookwood Rushmere Saltmarsh Shepperd Silverthorn Stonebridge Stoutwell Thatcher Thornbury Tillingham
        Underhill Wainwright Warrender Westbrook Whitlow Wickham Wildermoor Woodhouse Wrenfield Yarborough
        Ambler Bywater Dimmock Eastwood Fletcher Goodwin Harrowgate Kettering Lowther Mallory Nettleton
        Pemberton Rushworth Sandleford Tarrant Upfield Vickery Weatherby Cobbold Draycott`),
      epithet: p(`the Tall|the Ploughman|Half-Hand|the Tanner|Greycloak|the Borderer|the Wanderer|Goodheart|
        the Swift|Stoneface|the Farrier|Longshanks|the Miller|Redbeard|the Ferryman|the Hedge-Knight|
        Blackthorn|the Lucky|the Unlucky|the Drover|the Reeve|Silverhair|the Brewer|the Watchman|Deepwell|
        the Fowler|Fairhand|the Tinker|the Shepherd|Wolfsbane|the Carter|Ashborn|the Chandler|
        the Gravedigger|Mudboots|the Weaver|the Bold|the Kind|Thistledown|the Beekeeper`),
    },
    shapes: {
      given: ['{given}'],
      'given+family': ['{given} {family}'],
      epithet: ['{given} {epithet}', '{given} {family} {epithet}'],
    },
    defaultShape: 'given+family',
  } },
};

const wolfPre = w(`Gra Kor Vul Rak Tor Hro Skar Brak Dur Fen Grol Hask Jor Kha Lup Mar Nor Orl Rog Sar Thar Ulf
  Var Wol Yor Zar Ak Bar Dro Gar Ash Bran Cor Dar Esk Fal Gorm Hal Isk Kel Lok Mord Nar Orr Rhu Tul Ur Vak
  Yar Skel`);
const pfWolfen = {
  id: 'pf-wolfen', label: 'Wolfen', games: ['palladium-fantasy'], cultures: ['wolfen', 'lupine', 'tribal'],
  blurb: 'The wolf-folk of the northern forests: a hard name, a pack, and a deed to be known by.',
  kinds: { person: {
    lists: {
      given: {
        masc: join(wolfPre, w('ak ul or rak gar oth ran ug eth kan rok vul ash grim dar ek hul rik vor gan orr tan mak drek han')),
        fem: join(wolfPre, w('a ra ika essa yra ena ia ka ith ara una ela ysha oka rin e ira yla esh anna vi sha ula eka ryn')),
        neutral: join(wolfPre, w('i en is ar el u ir ov ol an ys')),
      },
      pack: w(`Blackwater Redfang Frostmane Ironpaw Longmoon Ashfur Stonejaw Greyhowl Thornback Rimewind
        Emberclaw Deeproot Stormhowl Mistfang Bloodmoon Silverclaw Duskmane Nightrunner Bonebreaker
        Hillstalker Riverfang Snowtrack Oakheart Rockhowl Swiftpaw Ravenmane Gloomfang Brightclaw Deathhowl
        Coldwater Burntfang Longtooth Grimpaw Wildmane Cinderhowl Scarjaw Shadowtrack Brokenfang Highmoon
        Starfang Emberfall Hollowmoon Longwinter Thunderpaw Mossback Saltfang Duskhowl Ironwood Farhowl
        Greytrack`),
      epithet: w(`Longfang Ironhide Gutripper Swiftclaw Oathkeeper Moonborn Bloodtooth Grimjaw Stormcaller
        Shieldbreaker Deathhowl Frostpelt Bonegnawer Redmuzzle Truescent Nightwatcher Oakbreaker Ashpelt
        Pathfinder Snarl Ironjaw Hollowhowl Fangbreaker Mooncaller Ashtrack Kinslayer Bloodoath Snowmane
        Ridgewalker Thornhide Dawnhowl`).concat(p(`the Howler|the Elder|the Scarred|the Tracker|the Wise|
        the Exile|the Hunter|the Grey|the Loyal|the Silent|the Proud|the Old|the Lame|the Fierce|the Young|
        the Swift|the Patient|the Seer`)),
    },
    shapes: {
      given: ['{given}'],
      'given+family': ['{given} of the {pack} Pack'],
      epithet: ['{given} {epithet}', '{given} {epithet} of the {pack} Pack'],
    },
    defaultShape: 'given+family',
  } },
};

const elfPre = w(`Ae Cael Ela Fae Gal Ith Lae Mel Nae Ruv Sil Thal Vae Ael Cir Ery Fin Hal Ilm Lor Mir Nim Ory
  Qua Sae Tae Uvi Yl Ara Eli Ama Bel Cel Dae Eru Fea Gil Iri Ky Lue Mae Nel Oro Pel Rae Sel Tir Val Xae
  Yse`);
const pfElf = {
  id: 'pf-elf', label: 'Elf', games: ['palladium-fantasy'], cultures: ['elf', 'elven', 'sylvan'],
  blurb: 'Long, flowing names and a family name that remembers a place in the old forests.',
  kinds: { person: {
    lists: {
      given: {
        masc: join(elfPre, w('ndor rion las thil rian vel orn dir andil ros aron evan imar ithil orin eth dras lion vir nor thas mion ril dan lor ven')),
        fem: join(elfPre, w('wen iel ara ielle wyn eth lia riel anna ise rae yra ssa lin dra ne thiel nora wyth ela ssia lune dhra ria sael iwen')),
        neutral: join(elfPre, w('ae is en al yn il or e ir ys ael ien')),
      },
      fpre: w(`Silver Moon Star Dawn Mist Sun Willow Ash Frost River Rose Thorn Wind Glimmer Song Night Sky
        Fern Swift Dew Gold Oak Brook Cloud Amber Ivy Pearl Birch Lark Hawk`),
      fsuf: w(`bough whisper song bloom shade gleam brook wind veil thorn spire glade fall light crest weaver
        dancer strider ward petal shimmer glow root wing tide`),
      epithet: p(`the Fair|of the Hidden Vale|the Evening Star|Swiftarrow|the Lorekeeper|the Elder|
        the Wanderer|of the Silver Wood|the Moonblessed|Bladesinger|the Silent|Songweaver|the Exiled|
        the Farsighted|Starborn|the Twilight|Leafwalker|the Gentle|the Sorrowful|Dawnbringer|the Unwearied|
        Stormbow|the Graceful|Windrunner|the Patient|the Merciless|Ashwarden|the Quick|the Ageless|
        Thornguard|the Dreamer|the Keen|Riverwise|the Proud|Mistcloak|the Mourner|Oathsworn|the Radiant|
        Glade-Warden|the Unforgetting|Starwhisper|the Unbound|Moonshadow|the Evergreen|Lightfoot`),
    },
    shapes: {
      given: ['{given}'],
      'given+family': ['{given} {fpre}{fsuf}'],
      epithet: ['{given} {epithet}', '{given} {fpre}{fsuf} {epithet}'],
    },
    defaultShape: 'given+family',
  } },
};

const dwarfPre = w(`Bal Bor Brun Dag Dol Dur Grim Grom Hal Har Kel Kor Mag Mor Nor Orm Rag Rur Thal Thor Tor Ulf
  Vor Bram Drak Gund Hrol Kaz Stor Yor Ang Bur Dvar Eik Fal Gar Hjal Keld Lod Mund Nal Ost Rok Skal Tram
  Ung Val Wor Zak Bof`);
const pfDwarf = {
  id: 'pf-dwarf', label: 'Dwarf', games: ['palladium-fantasy'], cultures: ['dwarf', 'dwarven', 'mountain'],
  blurb: 'Short, heavy names and a clan name forged from stone, metal and trade.',
  kinds: { person: {
    lists: {
      given: {
        masc: join(dwarfPre, w('in ar ok rim dor grin li nar dek rak ur bold gar rik stan un grum vek thor bur mek ald orn gin')),
        fem: join(dwarfPre, w('a hild dis ra na run ella gret ya ika dra vi la ssa hera ly gunn dora lind rid wyn isa beth ga')),
        neutral: join(dwarfPre, w('i en o ir is al ek ul')),
      },
      cpre: w(`Iron Stone Copper Granite Anvil Hammer Deep Gold Coal Flint Forge Silver Bronze Rune Axe
        Boulder Grey Black Steel Tin Oak Crag Mountain Cinder Ember Hearth Brass Slate Quartz Obsidian`),
      csuf: w(`vein beard fist delve shield helm brow mantle heart hand breaker cutter mace song ward bottom
        back belly foot grip pick tongs kettle chisel lantern`),
      epithet: p(`the Stubborn|Ironbeard|the Deep-Delver|Oathkeeper|the Brewmaster|Stonehand|the Grudging|
        Anvil-Born|the Grey|Hammerfall|the Tunnel-Rat|Goldcounter|the Old|the Runesmith|Axebiter|
        the Unmovable|Coal-Eyes|the Loud|Mountainheart|the Wanderer|Trollbane|the Wise|Firebeard|
        the Miner|Gemfinder|the Silent|Bristleback|the Proud|Shieldwall|the Honest|Ale-Belly|the Mason|
        Steelskin|the Bitter|Flintspark|the Steadfast|Lampbearer|the Deepborn|Rockjaw|the Last Delver|
        Oreseeker|the Tallyman|Seamfinder|the Cavern-Lord`),
    },
    shapes: {
      given: ['{given}'],
      'given+family': ['{given} {cpre}{csuf}'],
      epithet: ['{given} {epithet}', '{given} {cpre}{csuf} {epithet}'],
    },
    defaultShape: 'given+family',
  } },
};

const orcPre = w(`Gro Kru Mog Ug Zag Bla Gor Dru Ska Thu Vra Ruk Nar Grub Snag Bul Hork Mur Gash Lug Brog Krag
  Durz Yag Zug Azg Bog Drak Fug Grash Hrug Jag Kog Lurz Mauk Nog Ork Prag Rukh Shag Tug Uzg Vug Worg Zurk`);
const pfOrc = {
  id: 'pf-orc-ogre', label: 'Orc and ogre', games: ['palladium-fantasy'],
  cultures: ['orc', 'ogre', 'goblinoid', 'tribal'],
  blurb: 'Harsh, short names, a tribe, and whatever the others started calling them after the last raid.',
  kinds: { person: {
    lists: {
      given: {
        masc: join(orcPre, w('ash nak gul tar zog rot ug mash grak dush bol kul rag gut nar uk gash thak bruk dak lok murg narg zuk hol dreg')),
        fem: join(orcPre, w('a ga ush ra ka zha uga ola rsha gra ba na shka ruga nazh ogga ilsh zura')),
        neutral: join(orcPre, w('o ik az ub ez og um ak ur ish oz')),
      },
      tribe: p(`Broken Tusk|Red Hand|Black Mire|Bone Hill|Ash Fang|Rotting Moon|Split Skull|Burning Eye|
        Gnawed Bone|Iron Tooth|Mud Wallow|Sky Biter|Blood River|Crow Feast|Stone Maw|Low Fire|Grey Dog|
        Rusted Blade|Howling Pit|Dead Tree|Bitter Water|Cracked Shield|Many Scars|Screaming Hill|
        Black Tongue|Sour Marsh|Twin Axe|Bent Spear|Cold Hearth|Hungry Wolf|Dung Heap|Torn Ear|
        Smoke Hollow|Bone Drum|Red Mud|Shattered Moon|Wart Hill|Long Grudge|Flayed Hide|Iron Pig|
        Gutted Stag|Salt Tooth|Brass Nose|Wet Bone|Stolen Horse|Fallen Tower|Grinding Jaw|Charred Pine|
        Eight Toes|Black Vulture|Rust Fang|Low Moon|Sour Tusk`),
      epithet: w(`Skullsplitter Gutripper Bonecruncher Ironbelly Eye-Gouger Blacktooth Two-Axe Manflayer
        Toe-Biter Stonefist Gristle Headtaker Spleenrot Bloodgut Wallbreaker Rot-Tooth Chainbreaker Mudskull
        Horsechewer Warbanner Split-Lip Ashmaw Gravemaker One-Tusk Rockeater Stomp Doomhowl Kneecracker
        Tentburner Skullcup Mawgrinder Flesh-Tearer Ribsnapper Stonegut Hill-Breaker Doorkicker Dogbiter
        Pitlord Stinkfoot Gravel-Voice`).concat(
        p(`the Stinking|the Hungry|the Loud|the Big|the Ugly|the Greedy|the Clever|the Brute|the Slow|
          the Cunning|the Mean|the Hollow`)),
    },
    shapes: {
      given: ['{given}'],
      'given+family': ['{given} of the {tribe}'],
      epithet: ['{given} {epithet}', '{given} {epithet} of the {tribe}'],
    },
    defaultShape: 'epithet',
  } },
};

const pfPlaces = {
  id: 'pf-places', label: 'Palladium Fantasy places and guilds', games: ['palladium-fantasy'],
  cultures: ['medieval', 'town', 'city'],
  blurb: 'Taverns and inns, guild shops, sailing ships, city wards and thieves\' guilds.',
  kinds: {
    tavern: {
      lists: {
        adj: w(`Gilded Drunken Rusty Sleeping Laughing Crooked Weary Wandering Silver Golden Black Red Green
          Jolly Merry Prancing Howling Singing Broken Lucky Lame One-Eyed Three-Legged Foaming Painted Hollow
          Salted Wicked Honest Tipsy Crowned Burning Frozen Leaping Dancing Grinning Wooden Copper Blind
          Proud Muddy Last Weeping Sly Contented`),
        noun: w(`Stag Boar Griffin Dragon Goose Badger Hart Hound Raven Kettle Lantern Anchor Crown Tankard
          Wheel Plough Barrel Harp Bell Candle Fox Mermaid Ogre Unicorn Wyvern Pony Cockerel Wolf Pig Otter
          Owl Heron Serpent Shield Sword Horseshoe Mill Bridge Oak Rose Thistle Knight Pilgrim Beggar Maiden`),
        noun2: w(`Thimble Ladle Anvil Spindle Flagon Crook Pitchfork Saddle Trumpet Quill Compass Chalice Drum
          Lute Mitre Hourglass Key Kettle Candlestick Sickle Scythe Bucket Cauldron Bellows Tinderbox Apple
          Pear Plum Acorn Hen Toad Magpie Weasel Hedgehog Bishop Jester Hermit Tinker Friar Squire`),
        owner: p(`Old Garrow|Widow Pell|Brannock|Mistress Alda|Fat Hobb|Gammer Wen|Blind Osric|Red Maude|
          Tall Jory|Granny Sithe|Mother Brune|Goodman Tuck|Aunt Hessa|Uncle Fitch|Lame Wat|Dame Idony|
          Brother Anselm|Sister Clem|Merry Nell|Squire Hale|Black Ulric|Pale Edda|Farmer Cobb|Old Nan|
          Captain Ferris|Long Tom|Little Mab|Goody Grist|Wicked Wenna|Honest Hal|One-Hand Rolf|Gentle Lettice|
          Master Pim|Mother Osyth|Sour Selwyn|Tipsy Tamsin|Grey Godric|Fair Rowena|Deaf Dunstan|Mad Mildra`),
        house: w(`Rest Hearth Taproom Alehouse Inn Cellar Lodge Board Roost Snug Den Cup Keg Table Lantern`),
      },
      patterns: ['The {adj} {noun}', 'The {noun} and {noun2}', '{owner}\'s {house}'],
    },
    shop: {
      lists: {
        surname: w(`Harrow Tallow Greave Pellam Cobble Farrow Wickett Brand Dunning Mercer Holloway Pike Fenn
          Garner Oakes Thackery Ruddle Ashby Kettle Quill Barrow Staple Loder Vane Crale Hobson Tunney Wattle
          Gorse Parrish Loom Bracken Coyne Fairlie Hask Iddon Jessop Kemble Lark Nyman`),
        kin: p(`Sons|Daughters|Sisters|Brothers|Kin|Nephews|Partners|Company|Heirs|Apprentices`),
        trade: p(`Smithy|Tannery|Cooperage|Apothecary|Chandlery|Bakery|Cartwright|Fletchery|Bookbindery|
          Tailory|Cobblery|Jewellers|Money-Changer|Saddlery|Armoury|Glassworks|Potteries|Herbalist|Dyeworks|
          Ropewalk|Scriptorium|Tinsmith|Locksmith|Brewery|Butchery|Mill|Weavery|Furriers|Map-Maker|
          Clockworks|Alchemist|Spicery|Wine Merchant|Candle-Works|Stonecutter|Bowyer|Silversmith|Perfumery|
          Curiosities|Scrivener`),
        adj: w(`Honest Golden Silver Copper Iron Careful Lucky Busy Crooked Patient Clever Humble Proud Good
          Merry Quiet Bright Old Little Tidy Cheap Fine Sturdy Swift True Worthy Thrifty Sharp Steady Stout`),
        ware: w(`Needle Anvil Quill Kettle Ledger Scale Loom Lamp Crucible Hammer Thimble Mortar Bellows Chisel
          Awl Spindle Button Ribbon Lantern Buckle Horn Bottle Scroll Map Key Coin Ring Candle Boot Cloak
          Barrel Basket Jar Bow Arrow Shield Helm Saddle Spoon Comb`),
      },
      patterns: ['{surname}\'s {trade}', '{surname} & {kin}', 'The {adj} {ware}'],
    },
    ship: {
      lists: {
        sadj: w(`Swift Salt Grey Silver Golden Crimson Faithful Wandering Restless Laughing Weeping Merry Proud
          Brave Bold Fair Lucky Northern Southern Western Eastern Midnight Morning Evening Stormy Quiet Wild
          Gentle Honest Crooked Old Young Last First Lonely Drunken Singing Dancing Sleeping Painted`),
        snoun: w(`Gull Heron Swan Dolphin Seal Maiden Widow Bride Queen Duchess Pilgrim Merchant Wanderer Rover
          Harp Lantern Star Moon Sun Tide Wave Wind Gale Current Anchor Compass Oar Sail Mast Keel Pearl Shell
          Coral Mermaid Serpent Kraken Albatross Petrel Cormorant Otter`),
        sname: w(`Endeavour Resolute Fortune Albatross Tempest Wanderlust Providence Constance Prudence Mercy
          Patience Charity Felicity Serenity Clemency Temperance Hope Faith Grace Valour Enterprise Venture
          Bounty Plenty Harvest Sovereign Regent Herald Courier Messenger Emissary Envoy Dauntless Steadfast
          Fearless Gallant Intrepid Vigilant Tireless Undaunted`),
        sowner: p(`Merchant|Widow|Fisher|Sailor|Captain|Bishop|Queen|Baron|Pilgrim|Harbourmaster|Admiral|
          Smuggler|Pirate|Sister|Mother|Father|Duke|Lady|Prince|Beggar`),
        sgift: w(`Fancy Hope Folly Pride Luck Prize Delight Gamble Promise Revenge Fortune Wager Blessing
          Burden Secret Treasure Dream Lament Joy Ransom`),
      },
      patterns: ['The {sadj} {snoun}', '{sname}', 'The {sowner}\'s {sgift}'],
    },
    district: {
      lists: {
        dname: w(`Tanners Coopers Chandlers Weavers Dyers Fullers Masons Smiths Cutlers Glaziers Potters Brewers
          Vintners Fishers Saltmakers Ropers Carters Tinkers Bakers Butchers Goldsmiths Scribes Candlemakers
          Furriers Hatters Cobblers Bowyers Fletchers Millers Shipwrights Sailmakers Wainwrights Drapers
          Hosiers Mercers Grocers Spicers Barbers Porters Lamplighters`),
        dplace: p(`Row|Lanes|Hill|End|Cross|Gate|Wharf|Yard|Close|Rise|Market|Commons|Hollow|Steps|Bridge|
          Quarter|Heights|Green|Mews|Docks`),
        dfeat: p(`Shambles|Warrens|Narrows|Stews|Old Walls|Temple Mount|Little Harbour|Beggars' Maze|
          Crooked Mile|Sunken Market|High Terraces|Gallows Green|Weeping Steps|Burnt Ward|Guild Hill|
          Kings' Garden|Lantern Quay|Ninefold Bridges|Silt Flats|Chapel Rise|Bell Tower|Moat Streets|
          Rag Fair|Salt Pans|Pilgrims' Rest|Scholars' Walk|Fishbone Alleys|Tilted Roofs|Muddy Banks|
          Copper Domes|Red Lanterns|Old Barracks|Widows' Row|Mill Race|Plague Pits|Horse Fair|Dragon's Gate|
          Nobles' Hill|Drowned Quarter|Five Wells`),
      },
      patterns: ['{dname} {dplace}', 'The {dfeat}', '{dname}\' Ward'],
    },
    gang: {
      lists: {
        gadj: w(`Silent Grey Velvet Crimson Nameless Knotted Laughing Midnight Hooded Gilded Black Hidden Quiet
          Smiling Crooked Broken Masked Shadowed Pale Weeping Hungry Patient Seventh Last Iron Silver Golden
          Copper Bloody Rusty Sleeping Blind Barefoot Lame Honest Merry Wicked Faceless Sly Humble`),
        gnoun: w(`Hands Knives Cloaks Fingers Masks Keys Rats Crows Shadows Coins Whisperers Brotherhood
          Sisterhood Company Guild Circle Cutpurses Ravens Moles Magpies Jackals Foxes Eels Lampblacks
          Sparrows Owls Wolves Spiders Ferrets Hounds Cats Toads Beetles Mice Weasels Vipers Wasps Fraternity
          Lantern-Men Nightwalkers`),
        gplace: w(`Docks Shambles Sewers Rooftops Narrows Market Graveyard Warrens Wharves Stews Bridges Alleys
          Gutter Cellars Chimneys Tunnels Mud Fens Bells Gallows`),
      },
      patterns: ['The {gadj} {gnoun}', 'The {gnoun} of the {gplace}'],
    },
  },
};

// ═══════════════════════ NIGHTBANE ═══════════════════════

const nbModern = {
  id: 'nb-modern', label: 'Modern everyday', games: ['nightbane', 'generic'],
  cultures: ['human', 'modern', 'american'],
  blurb: 'The names of ordinary people in an ordinary city - which is the point.',
  kinds: { person: {
    lists: {
      given: {
        masc: w(`James John Robert Michael David William Richard Joseph Thomas Charles Christopher Daniel
          Matthew Anthony Mark Donald Steven Paul Andrew Joshua Kenneth Kevin Brian George Timothy Ronald
          Edward Jason Jeffrey Ryan Jacob Gary Nicholas Eric Jonathan Stephen Larry Justin Scott Brandon
          Benjamin Samuel Gregory Alexander Frank Patrick Raymond Jack Dennis Jerry Tyler Aaron Jose Adam
          Nathan Henry Douglas Zachary Peter Kyle Ethan Walter Noah Jeremy Christian Keith Roger Terry
          Gerald Harold Sean Austin Carl Arthur Lawrence Dylan`),
        fem: w(`Mary Patricia Jennifer Linda Elizabeth Barbara Susan Jessica Sarah Karen Lisa Nancy Betty
          Margaret Sandra Ashley Kimberly Emily Donna Michelle Carol Amanda Dorothy Melissa Deborah Stephanie
          Rebecca Sharon Laura Cynthia Kathleen Amy Angela Shirley Anna Brenda Pamela Emma Nicole Helen
          Samantha Katherine Christine Debra Rachel Carolyn Janet Catherine Maria Heather Diane Ruth Julie
          Olivia Joyce Virginia Victoria Kelly Lauren Christina Joan Evelyn Judith Megan Andrea Cheryl
          Hannah Jacqueline Martha Gloria Teresa Ann Sara Madison Frances Kathryn Janice Jean Abigail`),
        neutral: w(`Alex Jordan Taylor Morgan Casey Riley Jamie Avery Quinn Parker Reese Rowan Sage Skyler
          Cameron Dakota Emerson Finley Hayden Kendall Logan Peyton River Robin Sawyer Shawn Terry Blake
          Charlie Drew Elliott Frankie Jesse Kai Lee Micah Noel Remy Sam`),
      },
      family: w(`Smith Johnson Williams Brown Jones Garcia Miller Davis Rodriguez Martinez Hernandez Lopez
        Gonzalez Wilson Anderson Thomas Taylor Moore Jackson Martin Lee Perez Thompson White Harris Sanchez
        Clark Ramirez Lewis Robinson Walker Young Allen King Wright Scott Torres Nguyen Hill Flores Green
        Adams Nelson Baker Hall Rivera Campbell Mitchell Carter Roberts Gomez Phillips Evans Turner Diaz
        Parker Cruz Edwards Collins Reyes Stewart Morris Morales Murphy Cook Rogers Gutierrez Ortiz Morgan
        Cooper Peterson Bailey Reed Kelly Howard Ramos Kim Cox Ward Richardson Watson Brooks Chavez Wood
        James Bennett Gray Mendoza Ruiz Hughes Price Alvarez Castillo Sanders Patel Myers Long Ross Foster`),
    },
    shapes: {
      given: ['{given}'],
      'given+family': ['{given} {family}'],
    },
    defaultShape: 'given+family',
  } },
};

const nlPre = w(`Mal Vor Nyx Sab Mor Xal Zeth Um Grav Ash Hel Crev Dus Obs Pall Sep Tenn Vesp Kry Lach Noc Rav
  Scor Thren Ebb`);
const nbCourt = {
  id: 'nb-nightlord-court', label: 'Nightlord court', games: ['nightbane'],
  cultures: ['nightlord', 'court', 'supernatural'],
  blurb: 'The Nightlords\' servants and courtiers: cold syllables, and a title that says what they are for.',
  kinds: { person: {
    lists: {
      given: {
        masc: join(nlPre, w('ius oth ane amon or ek ivar us erath aul ath ex eon ric ul orn')),
        fem: join(nlPre, w('ia ys ene ara ith essa yne ora ae ille anthe eth ira ysse ona a')),
        neutral: join(nlPre, w('is en ar el yr os ai ix')),
      },
      epithet: p(`the Unlit|Keeper of Mirrors|Warden of the Long Night|the Veiled|Hand of the Court|
        the Gloam-Herald|of the Shattered Glass|the Hushed|Collector of Faces|the Lampless|
        Voice of the Eclipse|the Unmoving|Seneschal of Shadows|the Ninth Chair|Warden of Sleep|
        the Cold Gaze|Keeper of Keys|the Sunless|of the Last Hour|Speaker of Silence|the Smiling|
        Harrower of Dreams|the Starved|Herald of Dusk|the Pale|Bearer of Masks|the Ashen Envoy|
        Watcher at the Threshold|the Grey Chancellor|the Unseen|of the Hollow Hours|the Patient Hunger|
        Scribe of Shadows|the Drowned|Lantern-Eater|the Merciless|Warden of Mirrors|the Candle-Snuffer|
        the Twelfth Shade|the Long Shadow`),
    },
    shapes: {
      given: ['{given}'],
      epithet: ['{given} {epithet}'],
    },
    defaultShape: 'epithet',
  } },
};

const nbPlaces = {
  id: 'nb-places', label: 'Nightbane city places and cults', games: ['nightbane', 'generic'],
  cultures: ['modern', 'city', 'urban'],
  blurb: 'Bars, businesses, neighbourhoods and the cults that meet in their back rooms.',
  kinds: {
    tavern: {
      lists: {
        adj: w(`Blue Red Black Velvet Neon Rusty Broken Lucky Last Midnight Crooked Lonely Sleepy Golden Silver
          Copper Smoky Rainy Dusty Busted Happy Sad Dirty Quiet Loud Tired Crimson Lost Little Old Twisted
          Burning Frozen Hollow Empty Painted Drowned Bent Wandering Paper`),
        noun: w(`Moon Lantern Anchor Owl Crow Raven Rooster Goat Stag Fox Hound Pig Mule Cat Mermaid Parrot
          Flamingo Jukebox Piano Trumpet Guitar Cellar Attic Door Window Mirror Clock Candle Match Bottle
          Glass Barrel Key Lock Needle Thread Record Radio Telephone`),
        owner: p(`Eddie|Maggie|Sal|Rosie|Big Mike|Frankie|Lou|Donna|Earl|Mo|Tony|Dot|Vic|Marge|Rick|Bev|
          Gus|Deb|Hank|Jo|Chuck|Pearl|Ray|Norma|Al|Flo|Stan|Irene|Duke|Babs|Joe|Lil|Mac|Rita|Nick|Gert|
          Walt|Fay|Ernie|Viv`),
        house: w(`Place Tavern Bar Lounge Pub Tap Room Joint Club Corner`),
      },
      patterns: ['The {adj} {noun}', '{owner}\'s {house}', '{owner}\'s'],
    },
    shop: {
      lists: {
        name: w(`Patterson Hollis Brennan Kowalski Nguyen Castillo Abernathy Delgado Fitzgerald Greenberg
          Hanley Iverson Jablonski Kaplan Lindqvist Moretti Novak Okafor Petrakis Quintero Rosenthal Sorensen
          Takahashi Underwood Valdez Whitaker Yamamoto Zielinski Albright Beaumont Carmichael Donnelly
          Ellsworth Fairbanks Gallagher Hargrove Ingram Jefferson Kingsley Lombard`),
        biz: p(`Pharmacy|Hardware|Laundromat|Dry Cleaning|Auto Repair|Pawn & Loan|Books|Records|Hair Salon|
          Barber Shop|Deli|Bakery|Florist|Funeral Home|Insurance|Realty|Bail Bonds|Tattoo|Pizza|Diner|
          Cafe|Liquor|Tailoring|Shoe Repair|Photo|Antiques|Pet Shop|Locksmith|Grocery|Newsstand|Hobby Shop|
          Music Shop|Thrift Store|Dental|Optometry|Taxidermy|Watch Repair|Appliance|Printing|Storage`),
        brand: p(`Sunrise|Evergreen|Main Street|Northside|Riverside|Blue Ribbon|Gold Star|Liberty|Pioneer|
          Crescent|Summit|Heritage|Keystone|Lakeview|Parkside|Silver Line|Starlight|Twin Pines|Valley|
          Westgate|Corner|Hometown|Midtown|All-Night|Downtown|Harbor|Maple|Oakwood|Elm Street|Union|
          Central|Metro|City Line|Eastside|Greenway|Highland|Ironworks|Jubilee|Kingston|Lighthouse`),
      },
      patterns: ['{name}\'s {biz}', '{brand} {biz}', '{name} & Sons {biz}'],
    },
    district: {
      lists: {
        dname: w(`Ash Birch Cedar Elm Maple Oak Pine Willow Chestnut Hawthorn Juniper Laurel Magnolia Poplar
          Sycamore Walnut Alder Aspen Beech Cypress Harbor River Lake Mill Brick Stone Iron Rail Canal Bridge
          Market Church College Garden Park Hill Meadow Spring Fountain Station`),
        dplace: p(`Heights|Hills|Park|Gardens|Village|Flats|Commons|Square|Terrace|Crossing|Row|Point|End|
          Side|Grove|Court|Landing|Bottoms|Yards|Junction`),
        dcompass: p(`North|South|East|West|Old|New|Upper|Lower|Little|Greater`),
      },
      patterns: ['{dname} {dplace}', '{dcompass} {dname}', '{dcompass} {dname} {dplace}'],
    },
    gang: {
      lists: {
        cadj: w(`Hollow Silent Pale Veiled Seventh Final Eternal Unbroken Weeping Waking Dreaming Sleeping
          Burning Frozen Shattered Hidden Secret Ancient Endless Radiant Dimming Returning Watching Waiting
          Starving Smiling Faceless Nameless Mirrored Sunless Last First Open Closed Inner Outer Black Grey
          White Red`),
        cnoun: w(`Eye Hand Mirror Door Gate Lamp Candle Moon Star Mask Key Choir Circle Church Congregation
          Order Fellowship Society Lodge Temple Assembly Chorus Covenant Brotherhood Sisterhood Family Flock
          Children Heirs Keepers Watchers Sleepers Dreamers Seekers Faithful Chosen Witnesses Hollow Veil
          Threshold`),
        cthing: w(`Dawn Dusk Night Silence Mirrors Dreams Ashes Hours Masks Shadows Echoes Glass Thorns Salt
          Smoke Dust Bones Keys Doors Stars`),
      },
      patterns: ['The {cadj} {cnoun}', 'The {cnoun} of {cthing}', 'Children of the {cadj} {cnoun}'],
    },
  },
};

export const THEMES = [
  riftsFrontier, riftsCoalition, riftsStreet, riftsDogBoy, riftsAtlantean, riftsSovietski, riftsPlaces,
  pfWestern, pfEastern, pfWolfen, pfElf, pfDwarf, pfOrc, pfPlaces,
  nbModern, nbCourt, nbPlaces,
];

// ── defaults ──
// The theme a class starts on. Keyed by class_id (imported_classes.class_id);
// a class not listed here falls back to its game's default below. A race is
// looked up as well as an occupation, and the occupation wins.
const each = (ids, theme) => Object.fromEntries(w(ids).map((id) => [id, theme]));
export const CLASS_THEMES = {
  // Palladium Fantasy races
  ...each('wolfen', 'pf-wolfen'),
  ...each('elf changeling', 'pf-elf'),
  ...each('dwarf gnome', 'pf-dwarf'),
  ...each('orc ogre troll goblin hob-goblin kobold troglodyte', 'pf-orc-ogre'),
  ...each('noble knight palladin squire', 'pf-western-empire'),
  // Rifts: the Coalition's own, its Dog Boys, its streets, Russia, and the
  // Wolfen who turn up there too - a Wolfen gets Wolfen names in any game.
  ...each(`coalition-grunt coalition-juicer coalition-samas-pilot coalition-technical-officer
    psi-stalker psycho-stalker`, 'rifts-coalition'),
  ...each('dog-boy', 'rifts-dog-boy'),
  ...each(`juicer juicer-assassin juicer-gladiator juicer-scout juicer-wannabe mega-juicer titan-juicer
    hyperion-juicer phaeton-juicer delphi-juicer dragon-juicer euro-juicer city-rat crazy
    headhunter-techno-warrior`, 'rifts-street'),
  ...each(`old-believer russian-fire-sorcerer russian-ley-line-walker russian-mystic-kuznya necromancer-russian
    slayer-russian gifted-one-russian gypsy-seer-russian gypsy-thief-russian gypsy-wizard-thief-russian`,
  'rifts-sovietski'),
  ...each('wolfen-quatoria space-wolfen', 'pf-wolfen'),
};
export const SYSTEM_THEMES = {
  rifts: 'rifts-frontier',
  'palladium-fantasy': 'pf-eastern-territory',
  nightbane: 'nb-modern',
  'heroes-unlimited': 'nb-modern',
};
export const PLACE_THEMES = {
  rifts: 'rifts-places',
  'palladium-fantasy': 'pf-places',
  nightbane: 'nb-places',
  'heroes-unlimited': 'nb-places',
};
