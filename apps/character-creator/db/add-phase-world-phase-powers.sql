-- The fifteen Phase Powers of Rifts Dimension Book 2: Phase World, printed
-- 32-35, as psionic_powers rows in a new category: Phase.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-phase-world-phase-powers.sql
--
-- WHY THESE ARE PSIONIC POWERS. The book's own first sentence on printed 32 is
-- "Phase powers seem to be a variation on psionic abilities. Like psionic
-- powers, they are activated by using I.S.P.", and each of the fifteen prints
-- Range, Duration, I.S.P. and a description - the exact column set this table
-- holds. Three of the four classes that reach them fuel phase and psionic
-- powers from ONE I.S.P. pool, which the book states outright for the phase
-- adept and the phase mystic. Filing them anywhere else would have cost them
-- the pick machinery in js/leveling.js, which is the whole of what the phase
-- adept grants.
--
-- WHY A FIFTH CATEGORY IS SAFE, AND IT WAS CHECKED RATHER THAN ASSUMED. The
-- category field in js/catalog-fields.js is a select carrying allowOther, with
-- a comment saying in as many words that a later book may add a category the
-- core four do not cover and that a stored value must never be rewritten to fit
-- the list. Nothing else enumerates the categories: advPsiPool in app.js
-- filters with allowed.includes(x.category) and sheet.js renders the heading as
-- "Psionics - <category>". The gate fails CLOSED, which is what makes this
-- safe: psiConfig in app.js defaults a class that states no categories_allowed
-- to the core four rather than to "anything", so no published class can reach a
-- Phase power by accident. The eight psionic classes that state no
-- categories_allowed were then checked one at a time - burster, godling, holy
-- terror, morphworm, shade, techno-wizard, termite engineer and vacuum wasp -
-- and not one of them has a powers_schedule or a powers_per_level, so none has
-- a level-up picker to leak through either. Only a class naming Phase reaches
-- these rows, and this batch adds the only two that do.
--
-- min_tier stays NULL on all fifteen, which is the catalog's overwhelming
-- default: the category is the gate. `isp` holds the MINIMUM cost, per the
-- field's own help text, and isp_note carries the schedule where the book
-- prints one.
--
-- Every number here was read off a 200 dpi render of printed 32, 33, 34 and 35,
-- and cross-checked against the book's own Alphabetical List of Phase Powers at
-- the head of printed 32, which prints each cost in parentheses. The OCR and
-- the renders agree on all fifteen.

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Anti-Phase', 'Phase', 30, NULL, 'rifts', '100 ft (30.5 m) plus 20 ft (6.1 m) per level of experience.', 'Instant', NULL, 'Cancels out any phase ability or field it strikes, including technological phase fields, temporal magic spells that involve spacial or time distortions, and any continuing phase power. Anti-phase works only on ONGOING phase effects: it will not damage weapons, heal damage caused by a phase blast, or undo something a phase power has already done.', 'import', 'Rifts Dimension Book 2: Phase World p.32-35'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Anti-Phase');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Close Rift', 'Phase', 200, 'plus 2 I.S.P. off the character''s PERMANENT I.S.P. base, every time', 'rifts', '100 feet (30.5 m)', 'Instant', 'The Rift saves against psionic attack, not against magic.', 'Works just like the close Rift magic spell in Rifts, page 189, except that the Rift gets to roll a save against psionic attack rather than against magic. The 2 I.S.P. above the 200 come out of the character''s permanent base and do not come back.', 'import', 'Rifts Dimension Book 2: Phase World p.32-35'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Close Rift');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'D-Phase', 'Phase', 15, NULL, 'rifts', 'Self', 'One melee round (15 seconds) per level of experience.', NULL, 'Warps and bends the dimensional aspects of reality so that the character can walk through solid matter. It takes great concentration. Losing concentration means failing to complete the phase, which causes a flash of light and throws the person back to where he started: 2D6 hit points of damage, icy cold to the touch, and dazed for 1D4 melees - one attack and no combat bonuses. The same pop back happens if the duration runs out while he is still inside an object. Air is the other limit: he must hold his breath for as long as the passage takes, and if his air runs out he loses concentration and pops back with the usual results.', 'import', 'Rifts Dimension Book 2: Phase World p.32-35'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'D-Phase');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'D-Shift Distance', 'Phase', 20, NULL, 'rifts', 'Varies', 'Instant', NULL, 'Twists space by a factor of ten: a 20 foot (6.1 m) distance can become two feet (0.6 m) for the user, or 200 feet (61 m) for somebody else. To observers his form seems to stretch or contract bizarrely - an arm reaching across twenty feet to land a punch, a target suddenly hundreds of feet away, a fired bullet curving to its mark. Each activation allows ONE melee attack or action that twists space, and speed is multiplied by ten for that action. It grants +10 to strike or dodge but NOT to parry, and no other combat bonus. It does not allow travel through solid objects, so a careless user can hit a wall at ten times normal speed. It will not work in an area protected by a phase field.', 'import', 'Rifts Dimension Book 2: Phase World p.32-35'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'D-Shift Distance');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'D-Shift Ghost', 'Phase', 50, NULL, 'rifts', 'Self', 'One minute (4 melees) per level of experience.', NULL, 'Removes the character from normal three-dimensional space, rendering him invisible and insubstantial. He can observe the three-dimensional world but is completely undetectable by normal means, including the see the invisible spell and its psionic equivalents. In ghost mode his speed drops to 4, but he can move in any direction including up and down and is unimpeded by normal barriers - phase, magic and force field barriers still stop him. He can perform NO actions in this state, including using other powers or spells: only move and watch.', 'import', 'Rifts Dimension Book 2: Phase World p.32-35'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'D-Shift Ghost');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Dimensional Leap', 'Phase', 10, NULL, 'rifts', 'Up to 120 ft (37 m)', 'Instant', NULL, 'The character phases out of our space-time continuum and reappears somewhere else, instantaneously - he disappears in a blink and is back a second later. Used in combat to appear behind an enemy or to avoid an attack; used defensively it gives +6 to dodge. Each leap counts as one melee attack or action. The destination must be VISIBLE to the person teleporting, and he cannot carry another person with him.', 'import', 'Rifts Dimension Book 2: Phase World p.32-35'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Dimensional Leap');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Fast Draw', 'Phase', 4, 'varies with distance: 4 on the body, 10 within a mile, 20 anywhere on the planet, 40 anywhere in the galaxy, 80 from another dimension', 'rifts', 'Varies', 'Instant', NULL, 'Summons an object the character has attuned to himself, even over great distances, so a phase adept is never truly unarmed. He can attune one object per level of experience; an attuned object cannot exceed 100 lbs (45 kg) and is usually a weapon or a tool. The cost varies with distance: 4 I.S.P. if the object is on his body, in a holster or a backpack; 10 I.S.P. within one mile (1.6 km); 20 I.S.P. anywhere on the planet; 40 I.S.P. anywhere in the galaxy; 80 I.S.P. and one full melee round (15 seconds) from another dimension. It will not work if either the character or the object is surrounded by a force field or a magic barrier of any sort, protection circles included.', 'import', 'Rifts Dimension Book 2: Phase World p.32-35'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Fast Draw');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Multi-Phase', 'Phase', 20, 'per duplicate form', 'rifts', '20 ft (6.1 m) per level of experience.', 'One minute (4 melees) per level of experience.', NULL, 'Creates one or more duplicates of the user by anchoring his form in more than one place in space-time. Only one form affects the physical world; the others can be seen and heard but are insubstantial projections, and attacks pass harmlessly through them. He chooses where the duplicates appear, within range, and they mirror what the real form is doing at that same instant. Unlike an illusion, he can SWITCH PLACES with any duplicate at any time - one melee attack or action, and it can be combined with a dodge to jump away before a blow lands. Phase weapons, ley line storms and a magic circle disperse a duplicate; sense and see dimensional anomalies, detect psionics, see aura, telepathy and empathy all reveal which one is flesh and blood.', 'import', 'Rifts Dimension Book 2: Phase World p.32-35'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Multi-Phase');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Phase Blast', 'Phase', 15, 'add 10 more to raise the strike bonus from +4 to +8', 'rifts', '100 feet (30.5 m) per level of experience.', 'Instant', NULL, 'A blast of disruptive phase waves doing 3D6 damage - S.D.C. against an S.D.C. target, mega-damage against a mega-damage one, so a human takes S.D.C. and a dragon takes M.D. The blast IGNORES conventional armor and goes right through it. It is stopped by force fields, magic armor and magic barriers, which take the full M.D. from it; by spells of protection; and by a circle of protection, which simply blocks it with no damage taken. Phase blasts are +4 to strike, or +8 for an extra 10 I.S.P.', 'import', 'Rifts Dimension Book 2: Phase World p.32-35'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Phase Blast');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Phase Field', 'Phase', 25, NULL, 'rifts', 'Self', 'One minute (4 melees) per level of experience.', NULL, 'A force field that disperses incoming energy, bullets from rail guns and projectile weapons included: non-magical attacks have their damage DIVIDED BY 10 before it is applied to armor or to the character. The field is useless against phase weapons, the phase blast power, magic attacks, magic weapons, and punches and kicks - which move too slowly to be affected - and all of those do full damage.', 'import', 'Rifts Dimension Book 2: Phase World p.32-35'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Phase Field');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Phase Warp: Confuse', 'Phase', 20, NULL, 'rifts', '90 ft (27.4 m)', 'One melee round (15 seconds) per level of the phase user.', 'Save versus psionics or suffer the penalties.', 'Twists space around the victim so that he is out of step with the physical world. His body constantly miscalculates distance and speed, so he bumps into things, misses his targets and trips over his own feet. A target who fails a save versus psionics is at -6 to strike, parry and dodge, and at -40% on all skills - or -60% on a skill that requires precise spacial measurement.', 'import', 'Rifts Dimension Book 2: Phase World p.32-35'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Phase Warp: Confuse');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Phase Warp: Displacement', 'Phase', 25, NULL, 'rifts', '100 feet (30.5 m) per level of experience.', 'Instant', 'An unwilling living being saves versus psionics to resist.', 'A teleport that affects objects and people rather than the user. The maximum weight is 100 pounds (45 kg) at first level plus 50 pounds (22.5 kg) per additional level of experience. The object or person must be in range and can be moved anywhere within that range. Unwilling living beings save versus psionics to resist. Nothing can be displaced INTO a living being or a solid object - walls, tables and the like - and people cannot be deliberately displaced into them either. This is strictly a spacial effect: it moves a thing from one place to another within the user''s range and does nothing else.', 'import', 'Rifts Dimension Book 2: Phase World p.32-35'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Phase Warp: Displacement');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Phase Warp: Split Persona', 'Phase', 30, 'per limb or body part separated', 'rifts', '20 ft (6.1 m) plus 10 ft (3 m) per level of experience.', 'One minute (4 melees) per level of experience.', 'If anti-phase is used successfully against a character using this power, he must save 12 or higher, adding P.E. bonuses, or the separated parts are severed or wrenched off.', 'Separates limbs and body parts and makes them reappear some distance away. It is a spacial distortion and the parts are still connected to the person: a gun hand can appear 40 feet (12.2 m) ahead, right behind the enemy he is facing, and he can actually shoot with it - though he must be able to SEE the hand to aim, and is at -3 to strike, or -8 shooting blind or wild. To an observer the hand looks sheared off at the wrist, bone and blood vessels visible but not bleeding. Other uses are snatching keys, opening a door, working a light or a device, knocking on a wall yards away, or sending one eye into the next room; sending the whole head or both eyes leaves the body defenseless. Both the user and the separated parts can be attacked normally and take normal damage, with a called shot at -2 to -6 needed for a small part. A split limb cannot penetrate a phase or magic barrier.', 'import', 'Rifts Dimension Book 2: Phase World p.32-35'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Phase Warp: Split Persona');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Spacial Distortion: Self', 'Phase', 15, NULL, 'rifts', 'Self', 'One minute (4 melee rounds) per level of experience.', NULL, 'A phase field that distorts space around the user: distance and his exact location are curved around him, and to a normal observer his form blurs and twists as in a funhouse mirror. Attacks that travel in straight lines or slight arcs - beam weapons, bullets, arrows - are at -4 to hit him. He also takes longer strides as he walks and runs, multiplying his normal speed by ten for the duration. Fourth-dimensional beings and many temporal magic spells can detect and neutralise this power.', 'import', 'Rifts Dimension Book 2: Phase World p.32-35'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Spacial Distortion: Self');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Spacial Distortion: Others', 'Phase', 20, NULL, 'rifts', '20 ft (6.1 m) per level of experience.', 'One minute (4 melees) per level of experience.', NULL, 'The same as Spacial Distortion: Self, except that it works on another person. If the subject is not a promethean, a phase mystic, or a temporal wizard or warrior, the distortion also impairs his senses: -1 on initiative, -2 to strike, parry and dodge, and -15% on all skills.', 'import', 'Rifts Dimension Book 2: Phase World p.32-35'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Spacial Distortion: Others');

-- Read the result back rather than trusting the exit code. Fifteen rows, all in
-- the Phase category, and nothing else in the catalog is in it.
SELECT COUNT(*) AS phase_powers, MIN(isp) AS cheapest, MAX(isp) AS dearest
  FROM psionic_powers WHERE category = 'Phase';
SELECT name, isp, isp_note FROM psionic_powers
  WHERE source_book = 'Rifts Dimension Book 2: Phase World p.32-35' ORDER BY name;

-- Records this run. One row per run rather than per file: every statement above
-- guards itself, so this script is safe to re-run. See
-- db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-phase-world-phase-powers.sql');
