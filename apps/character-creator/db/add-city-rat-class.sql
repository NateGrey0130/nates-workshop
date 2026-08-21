-- The City Rat O.C.C., Rifts Ultimate Edition p.88-88.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-city-rat-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-city-rat-class.sql
--
-- Extracted with the app's own class importer from the Rifts Ultimate Edition
-- PDF and validated with scripts/class-check.mjs before this file was
-- generated. Applied as a script rather than through the import UI because
-- production sits behind Cloudflare Access.
--
-- THE PDF HAS NO TEXT LAYER. All 382 pages are scanned images, so the model
-- read the pages as images rather than parsing text. That is what the importer
-- does anyway - it sends the PDF as a document attachment and never
-- pre-extracts text, because layout-preserving extraction splices neighbouring
-- columns together mid-line on a two-column sourcebook page.
--
-- SKILL BASES AND NAMES ARE POST-PROCESSED, not taken as extracted. The model
-- has the printed bonus ("+15%") but no catalog, so it returns base 0 and
-- strands the bonus in a note; the convention is that a skill's base is the
-- CATALOG base plus the printed bonus, already added. And RUE contradicts
-- itself on names - its class entries print "Basic Math" and "Lore: D-Bees"
-- where its own Skill List prints "Mathematics: Basic" and "Lore: D-Bee" - so
-- names are resolved through catalog_redirects to the canonical row. That
-- matters beyond tidiness: a restriction is matched by raw name, in the
-- browser, where redirects are not available.


-- The class itself. INSERT ... WHERE NOT EXISTS rather than INSERT OR IGNORE,
-- so re-running the script is a no-op instead of a silent partial write.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'city-rat', 'City Rat', 'rifts', '---
id: city-rat
name: City Rat
system: rifts
source_book: Rifts Ultimate Edition p.88-88
category: occ
attribute_requirements:
  IQ: 10
bonuses:
  combat: {}
  pools: { sdc: "2d4", ppe: "1d10+4" }
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 92, per_level: 1, note: "At 92%. Literate in Native Language (+15%)." }
    - { choose: 1, categories: ["Communications"], bonus: 10, note: "Language: Other, one of choice (+10%)." }
    - { name: "Barter", base: 45, per_level: 4 }
    - { name: "Computer Operation", base: 55, per_level: 5 }
    - { name: "Streetwise", base: 40, per_level: 4 }
    - { name: "Tailing", base: 50, per_level: 5 }
    - { name: "Automobile", base: 70, per_level: 2 }
    - { name: "Bicycling", base: 64, per_level: 4 }
    - { choose: 1, from: ["Motorcycles & Snowmobiles", "Hovercycles, Skycycles & Rocket Bikes"], note: "Pilot: Motorcycle (+15%) or Hovercycle (+10%)." }
    - { name: "Mathematics: Basic", base: 55, per_level: 5 }
    - { name: "Running", base: 0, per_level: 0 }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P.: One of choice." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Hand to Hand: Expert at the cost of one O.C.C. Related Skill, or Martial Arts (or Assassin, if an evil alignment) for the cost of two O.C.C. Related Skills." }
  occ_related_skills:
    count: 10
    categories:
      - "Communications"
      - "Domestic"
      - "Electrical"
      - "Mechanical"
      - "Medical"
      - "Physical"
      - "Pilot"
      - "Rogue"
      - "Science"
      - "Technical"
      - "Weapon Proficiencies"
    note: "At least three must be selected from Physical or Rogue skills. Communications: Any (+10%). Domestic: Any (+5%). Electrical: Basic and Computer Repair only (+5%). Mechanical: Automotive and Basic Mechanics only (+10%). Medical: First Aid or Paramedic (+10%); Paramedic counts as two skill selections. Physical: Any (+5% where applicable), except Fencing, Forced March, Outdoorsmanship, and SCUBA. Pilot: Any ground vehicles, Jet Pack, or Robot Combat: Basic (+10%), but no aircraft, boats, power armor, robots, or military vehicles. Rogue: Any (+15%). Science: Math: Basic and Advanced Chemistry only. Technical: Any (+10%). W.P.: Any, except any Heavy Energy Weapons and military W.P.s."
    schedule:
      - { level: 2, count: 1 }
      - { level: 4, count: 1 }
      - { level: 6, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
equipment_starting: []
extraction_notes: |
  - O.C.C. Bonuses text: "+2D4 to S.D.C., +1D6+1 to Spd attribute, +3 on
    Perception Rolls, and +1D10+4 to P.P.E. base (reduce amount by half when
    the character reaches age 22)." Spd and Perception bonuses have no clean
    home in the bonuses schema (Spd is an attribute die-add, not covered by
    the pools/attributes number-only convention for a roll applied post-chargen,
    and Perception Rolls is not a tracked pool/save) ' || char(8212) || ' recorded here as prose
    rather than forced into a field: +1D6+1 to Spd attribute, +3 on Perception
    Rolls. The P.P.E. bonus is recorded under pools.ppe; note the halving at
    age 22 is not expressible and stays prose.
  - "A third to half are D-Bees" is a racial-mix note, not a hard requirement,
    so it was omitted from attribute_requirements/restrictions.
  - Attribute Requirements text: "Generally the City Rat is fast, clever and
    agile, but there are no real requirements other than an I.Q. 10 or higher
    to be a hacker, P.P. of 10 or higher to be a thief, I.Q. 10 and P.P. 14 or
    higher to be an assassin, P.S. of 14 or higher to be a hero or thug/muscle
    man." Only the flat I.Q. 10 general baseline was captured as a hard
    requirement; the rest are conditional/role-specific thresholds and are kept
    as prose in GM Notes rather than encoded as universal requirements.
  - No equipment list, starting money, or alignment restriction list beyond
    "typically Unprincipled, Anarchist, Miscreant or Aberrant" appears on this
    page (that phrasing is advisory ["typically"], not a hard restriction, so
    it is recorded in Lore/GM Notes rather than as a restrictions entry).
  - Related O.C.C.s note ("See the Cyber-Doc...") belongs to the preceding
    entry (city/''Burbs doctor) on this page, not to City Rat, and was excluded.
---

## Lore

"The CS may think they own this place, and adults may run the show, but we''re the Kings and Queens of the streets. We know everything."

City Rats are the denizens of the ''Burbs and big cities. In the fortress cities modeled after Chi-Town, those who live in the lower levels of such a metropolis are generally nicknamed "Downsiders," but "City Rat" is a designation for a Downsider troublemaker and the street urchins who run amok in the ''Burbs. They exist in most urban environments, but absolutely thrive in the ''Burbs and the lower levels, tunnels, and sewers of Chi-Town, Iron Heart and other mega-cities of the Coalition States, the New German Republic, Mexico and Japan. Most have never been beyond the city limits and have no desire to go adventuring beyond the urban sprawl. These are "city people" through and through. They know little about the outside world except what they read or hear on the street, and view it as wondrous, scary, and alien, but most of all, a place not for them. Their world is the rumbling and bustling city streets. Their secret havens, hideouts and lairs are the shadowy dark places that other city dwellers have forgotten about or fear to enter.

City Rats love the acrid mix of smells that is the living city: machine oil, vehicle exhaust, booze, and perspiration of the thronging multitudes. They are not afraid of the city''s dark corners or its vermin. They know the back streets and, often, the alleys, sewer systems, and access tunnels in the belly of the beast that is the city. And they know them better than the average citizen knows the highways and avenues.

City Rats pride themselves on their knowledge of the streets and the movers and shakers who work them and the predators that prowl them. That means City Rats know where to find contraband, cybernetics, drugs, pawnshops, fences, Body-Chop-Shops, Black Market hangouts and hoods, the best food, the cheapest women, all night hot spots, and other places, resources and commodities on the streets. If you know where to look, you can find most anything you could need or want, and City Rats know all the ins and outs of *their* city.

The career of a City Rat is a *way of life* rather than an occupation. A lifestyle glamorized (and lived) as a sort of swashbuckling streetwise hacker and petty crook who travels the undercurrents of the city streets and the electronic super-highway with equal ease. It is a life of self-made intrigue, exploration, spying and thievery (of data if nothing else). City Rats are usually young men and women in their teens or twenties who walk on the wild side. They crave adventure and find it by bucking the system and dodging the law. A City Rat may be an idealistic rebel who seeks reform and justice in a corrupt and unjust society, or a simple thrill seeker who finds excitement and romance in the dark underbelly of the city and the subculture of the street scene. Many City Rats are computer hackers and information brokers, while others are little more than beggars and thieves, all surviving by the seat of their pants. The individual''s exact orientation and skills typically reflect his alignment, ideals, ethics, and goals.

## GM Notes

Alignment is typically Unprincipled, Anarchist, Miscreant or Aberrant, though this is advisory rather than a hard restriction ' || char(8212) || ' let a player''s concept guide exceptions.

Attribute guidance offered by the book for flavor/role rather than as hard prerequisites: I.Q. 10+ suits a hacker; P.P. 10+ suits a thief; I.Q. 10 and P.P. 14+ suits an assassin; P.S. 14+ suits a hero or thug/muscle-man type. Use these to help a player pick a City Rat "specialty" rather than gatekeeping the class.

Racial Requirements: none stated as a hard bar, but the book notes a third to half of City Rats are D-Bees ' || char(8212) || ' useful for GMs populating ''Burbs settings.

Related O.C.C.s referenced elsewhere on the page (psychic healing powers in this book, and the Herbologist O.C.C. and herbs from Rifts World Book 3: England) apply to the preceding City/''Burbs Doctor entry, not to City Rat.', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'city-rat');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'city-rat';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-city-rat-class.sql');
