-- The 37 skills Rifts World Book 25: China 2 adds that the catalog does not
-- already hold: 26 Domestic, Medical, Physical, Rogue and Technical skills,
-- four Ancient Chinese W.P.s and seven Hand to Hand styles.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-a-china-2-skills.sql
--
-- SCAN, page_offset +1 (scripts/books.json): printed F is cache p<F+1>. Every
-- base, per-level figure and level table was read off a 200 dpi render, by two
-- book-extract-workers. The survey is apps/character-creator/docs/surveys/china-2.md.
--
-- NAMES come from the New China Skills List on printed 13 and the Ancient
-- Chinese W.P. list on printed 14, which is what a class's skill list names.
-- Where a description heading differs (Silk Creation & Manufacture, Chemistry:
-- Chinese Alchemical, Lore: Western, White Jade Fan) the note says so.
--
-- 41 ON THE LIST, 37 HERE. Wei Qi/Go is Japan's Go (30% +5%, the same figures).
-- Fasting (54/4 here), Begging (8/1) and Calligraphy (25/5) are RUE rows at
-- different figures, and the RUE rows stand, as Japan's reprints did.
-- Literacy: Chinese is a new row by Nate's decision on 2026-10-01, not
-- Language: Chinese.
--
-- A STYLE'S DICE-VALUED BONUSES (Shao-Lin's +1D4 P.S., Tai Chi's 2D6 I.S.P.,
-- +1D6 damage) and its S.D.C. are in the level's note, not applied: a skill
-- can be taken at any level, so there is no moment to roll them. Starting
-- attacks are attacks_base; printed 19 says they already include hand to
-- hand's two. The W.P.s' strike and parry are applies_when, so they never
-- reach the unarmed combat block.
--
-- It SORTS FIRST among this book's scripts (add-a-), before the class scripts
-- that grant these rows by name. systems is written here as ["rifts"]; a clean
-- build clears it in fix-pf-armor-and-cross-system-gear.sql, and the tilde
-- script for this book re-tags these 37 after that.

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('Play Chinese Musical Instrument: Flute', 'Domestic', 45, 5, '["rifts"]', 'import',
        'Rifts World Book 25: China 2 p.13-14',
        'Playing the Chinese flute, with a repertoire of folk and classical tunes and the knack of improvising. A second figure, 25% +5% per level, is for building a playable flute from bamboo, wood, clay or metal.',
        NULL,
        NULL);

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('Rice Cultivation', 'Domestic', 40, 5, '["rifts"]', 'import',
        'Rifts World Book 25: China 2 p.13-14',
        'Growing rice by hand in flooded paddies. About 200 bushels a crop at first level, +10 per level; five bushels feed one person for a year; two crops a year in the south, one in the north. Taken twice, it adds handling water buffalo, which doubles the yield.',
        NULL,
        NULL);

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('Silk Manufacture', 'Domestic', 30, 5, '["rifts"]', 'import',
        'Rifts World Book 25: China 2 p.13-14',
        'Silk Creation & Manufacture (printed 14): every stage of silk-making, from raising silkworms to weaving and dyeing. Taken twice, it adds tailoring silk garments.',
        NULL,
        NULL);

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('Tea Appreciation', 'Domestic', 70, 2, '["rifts"]', 'import',
        'Rifts World Book 25: China 2 p.13-14',
        'Judging, blending, brewing and serving tea. A formal tea ceremony takes three rolls: blend, brew and serve.',
        NULL,
        NULL);

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('Tiao Qi/Chinese Checkers', 'Domestic', 24, 4, '["rifts"]', 'import',
        'Rifts World Book 25: China 2 p.13-14',
        'Chinese checkers played at a professional level. A multi-player game is settled by percentile plus I.Q. plus skill, highest wins. Many demon servitors of the Yama Kings are fanatical players.',
        NULL,
        NULL);

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('Xiang Qi/Shogi', 'Domestic', 15, 5, '["rifts"]', 'import',
        'Rifts World Book 25: China 2 p.13, 15',
        'Chinese chess. A game is settled by opposed skill rolls, repeated until one player succeeds and the other fails.',
        NULL,
        NULL);

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('Acupuncture', 'Medical', 40, 5, '["rifts"]', 'import',
        'Rifts World Book 25: China 2 p.13, 15',
        'Treating illness and blocking pain with needles at the body''s meridian points. Acupressure without needles is possible at -20%.',
        NULL,
        NULL);

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('Chinese Herbal Medicine', 'Medical', 30, 5, '["rifts"]', 'import',
        'Rifts World Book 25: China 2 p.13, 15',
        'The book''s equivalent of Holistic Medicine, drawing on a wider range of ingredients found only in Rifts China.',
        NULL,
        NULL);

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('Demon Wrestling', 'Physical', 30, 5, '["rifts"]', 'import',
        'Rifts World Book 25: China 2 p.13, 15',
        'Liang Hsiung: a dirty wrestling style modelled on how demons brawl. Moves: body block/tackle 1D8 (double for a wrestler 8-12 ft tall, 3D6 if larger); pin/incapacitate on 15 or better at level 1, 14 at 4, 13 at 8, 12 at 12; crush/squeeze 1D6 (same doubling); crush soft parts; +20% to conceal an illegal move; feign illegal injury, an acting skill at 30% +5% per level (+1% per M.A. point above 15). Also +4D6 S.D.C. and +1 to save vs pain at levels 3, 6, 9, 12 and 15, stated here and not applied. Its bonuses do not combine with Wrestling''s; a character takes one. The 30% +5% is the printed 13 list''s figure; the description prints a base only for the acting sub-skill.',
        '{"attributes":{"PS":3,"PE":3},"saves":{"pain":2}}',
        '[{"level":1,"combat":{"roll":1}},{"level":5,"combat":{"roll":1}},{"level":10,"combat":{"roll":1}},{"level":15,"combat":{"roll":1}}]');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('Meditation', 'Physical', 0, 0, '["rifts"]', 'import',
        'Rifts World Book 25: China 2 p.13, 16',
        'A calm, motionless trance that speeds the recovery of hit points, P.P.E., I.S.P. and Chi. The character stays aware and can break the pose with no combat penalty. Not a percentile skill: it succeeds on 10 or better on a D20, with only the M.E. bonus added, at any level.',
        NULL,
        NULL);

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('Calligraphic Forgery', 'Rogue', 25, 5, '["rifts"]', 'import',
        'Rifts World Book 25: China 2 p.13, 16',
        'Imitating ancient calligraphy well enough to pass copies off as originals; forging one particular author''s hand is -20%. Requires Calligraphy.',
        NULL,
        NULL);

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('Dickering', 'Rogue', 20, 4, '["rifts"]', 'import',
        'Rifts World Book 25: China 2 p.13, 16',
        'Bargaining. Honest dickering gets up to half off a purchase or double the price on a sale; dishonest dickering up to 75% off or five times the value, at the cost of a cheat''s reputation.',
        NULL,
        NULL);

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('Shell Game', 'Rogue', 20, 4, '["rifts"]', 'import',
        'Rifts World Book 25: China 2 p.13, 16-17',
        'Running the three-shell scam: on a success the mark guesses right only on 01-10%; a failure blows the trick. +6% with Palming.',
        NULL,
        NULL);

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('Yarrow Stick Counting', 'Rogue', 24, 3, '["rifts"]', 'import',
        'Rifts World Book 25: China 2 p.13, 17',
        'A fraudulent I Ching reading: the con artist counts the sticks to force the hexagram he wants. A failed roll means being caught.',
        NULL,
        NULL);

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('Chinese Alchemy', 'Technical', 25, 5, '["rifts"]', 'import',
        'Rifts World Book 25: China 2 p.13, 17',
        'Chemistry: Chinese Alchemical (printed 17): interpreting ancient alchemical texts and reproducing their elixirs with modern equivalents, taking one to six further rolls. Requires Literacy: Ancient & Classical Chinese, Chemistry and Biology.',
        NULL,
        NULL);

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('Chinese Antiquarianism', 'Technical', 30, 5, '["rifts"]', 'import',
        'Rifts World Book 25: China 2 p.13, 17',
        'Appraising and dealing in Chinese antiques and spotting fakes, with basic tests of gem and metal quality.',
        NULL,
        NULL);

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('History, Chinese', 'Technical', 40, 5, '["rifts"]', 'import',
        'Rifts World Book 25: China 2 p.13, 17',
        'Chinese history: dynasties, rulers and the works of the major writers, and dating an object by its style. Requires Literacy: Chinese.',
        NULL,
        NULL);

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('Imperial Bureaucracy & Administration', 'Technical', 10, 5, '["rifts"]', 'import',
        'Rifts World Book 25: China 2 p.13, 17',
        'Also called Bureaucracy & Administrative Organization: mastery of the Chinese imperial bureaucracy. At first level the character passes the civil service examinations and can organize any office''s paperwork or find any record. Gives +5% to Research, History and Literacy: Chinese, stated and not applied.',
        NULL,
        NULL);

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('Literacy: Chinese', 'Technical', 55, 5, '["rifts"]', 'import',
        'Rifts World Book 25: China 2 p.13, 17-18',
        'Reading and writing some 4,000 ideograms, enough for anything published from about 1900 on; earlier works are -85%. Filed under Technical as the book files it. A new row by Nate''s decision on 2026-10-01, not Language: Chinese.',
        NULL,
        NULL);

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('Literacy: Ancient & Classical Chinese', 'Technical', 50, 5, '["rifts"]', 'import',
        'Rifts World Book 25: China 2 p.13, 18',
        'Reading and writing over 20,000 characters in every script, back to pre-dynastic pictographs. Requires Literacy: Chinese.',
        NULL,
        NULL);

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('Lore: Chinese Classical Studies', 'Technical', 40, 5, '["rifts"]', 'import',
        'Rifts World Book 25: China 2 p.13, 18',
        'Mastery of the four classical categories of learning, the Five Sacred Books and the four Confucian books.',
        NULL,
        NULL);

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('Lore: Chinese Mythology: Taoist', 'Technical', 35, 5, '["rifts"]', 'import',
        'Rifts World Book 25: China 2 p.13, 18',
        'Chinese myth from the Taoist side: gods, ghosts, demons, dragons and immortals, and the background of the Yama Kings.',
        NULL,
        NULL);

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('Lore: Chinese Mythology: Buddhist', 'Technical', 35, 5, '["rifts"]', 'import',
        'Rifts World Book 25: China 2 p.13, 18',
        'The Buddhist counterpart of the Taoist lore, a separate skill. Hindu gods and spirits at -15%.',
        NULL,
        NULL);

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('Lore: Feng Shui/Geomancy', 'Technical', 15, 5, '["rifts"]', 'import',
        'Rifts World Book 25: China 2 p.13, 18',
        'Called Geomancy in the West: reading the Chi of a place, measuring flows of 0-8 points exactly and finding spots of very high or low Chi.',
        NULL,
        NULL);

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('Lore: Rifts China', 'Technical', 40, 4, '["rifts"]', 'import',
        'Rifts World Book 25: China 2 p.13, 18',
        'An outsider''s knowledge of Rifts China: its history, the Yama Kings'' politics, regional monsters, the free places, and a crude working vocabulary. Meant for characters from outside China; +10% for those from elsewhere in Asia, Japan, India, Mongolia or Russia.',
        NULL,
        NULL);

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('Lore: Western World', 'Technical', 30, 4, '["rifts"]', 'import',
        'Rifts World Book 25: China 2 p.13, 18',
        'Lore: Western (printed 18): a Rifts China native''s partial and often wrong knowledge of the outside world, classical and contemporary.',
        NULL,
        NULL);

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('W.P. Bamboo Staff', 'Weapon Proficiencies', 0, 0, '["rifts"]', 'import',
        'Rifts World Book 25: China 2 p.14, 19',
        'An Ancient Chinese Weapon Proficiency (listed printed 14, described 19). Only a character with one of these four W.P.s can make the weapon do Mega-Damage. A flexible bamboo pole that channels ambient P.P.E.: 1D6 M.D. per strike against M.D.C., supernatural and magic opponents. +1 M.D. at levels 4, 8 and 12.',
        NULL,
        '[{"level":1,"applies_when":"with a bamboo staff","combat":{"strike":1}},{"level":3,"applies_when":"with a bamboo staff","combat":{"strike":1}},{"level":5,"applies_when":"with a bamboo staff","combat":{"parry":1}},{"level":7,"applies_when":"with a bamboo staff","combat":{"strike":1}},{"level":10,"applies_when":"with a bamboo staff","combat":{"strike":1,"parry":1}},{"level":13,"applies_when":"with a bamboo staff","combat":{"strike":1}},{"level":15,"applies_when":"with a bamboo staff","combat":{"parry":1}}]');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('W.P. Chiang Zhu Spear', 'Weapon Proficiencies', 0, 0, '["rifts"]', 'import',
        'Rifts World Book 25: China 2 p.14, 19',
        'An Ancient Chinese Weapon Proficiency (listed printed 14, described 19). Only a character with one of these four W.P.s can make the weapon do Mega-Damage. A long, flexible spear that channels ambient P.P.E.: 2D4 M.D. per strike against M.D.C., supernatural and magic opponents. +2 M.D. at levels 1, 5 and 11.',
        NULL,
        '[{"level":2,"applies_when":"with a Chiang Zhu spear","combat":{"strike":1}},{"level":3,"applies_when":"with a Chiang Zhu spear","combat":{"parry":1}},{"level":4,"applies_when":"with a Chiang Zhu spear","combat":{"strike":1}},{"level":6,"applies_when":"with a Chiang Zhu spear","combat":{"parry":1}},{"level":8,"applies_when":"with a Chiang Zhu spear","combat":{"strike":1}},{"level":9,"applies_when":"with a Chiang Zhu spear","combat":{"parry":1}},{"level":12,"applies_when":"with a Chiang Zhu spear","combat":{"strike":1,"parry":1}},{"level":14,"applies_when":"with a Chiang Zhu spear","combat":{"strike":1}},{"level":15,"applies_when":"with a Chiang Zhu spear","combat":{"parry":1}}]');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('W.P. Gien Bian (Steel Whip)', 'Weapon Proficiencies', 0, 0, '["rifts"]', 'import',
        'Rifts World Book 25: China 2 p.14, 19',
        'An Ancient Chinese Weapon Proficiency (listed printed 14, described 19). Only a character with one of these four W.P.s can make the weapon do Mega-Damage. A flexible steel whip that channels ambient P.P.E.: 2D6 M.D. per strike against M.D.C., supernatural and magic opponents. +1 M.D. at levels 2, 5, 8, 11 and 14.',
        NULL,
        '[{"level":4,"applies_when":"with a steel whip","combat":{"strike":1}},{"level":5,"applies_when":"with a steel whip","combat":{"parry":1}},{"level":8,"applies_when":"with a steel whip","combat":{"strike":1}},{"level":10,"applies_when":"with a steel whip","combat":{"parry":1}},{"level":12,"applies_when":"with a steel whip","combat":{"strike":1}},{"level":15,"applies_when":"with a steel whip","combat":{"strike":1,"parry":1}}]');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('W.P. Wen Jen (Scholar''s Sword)', 'Weapon Proficiencies', 0, 0, '["rifts"]', 'import',
        'Rifts World Book 25: China 2 p.14, 19',
        'An Ancient Chinese Weapon Proficiency (listed printed 14, described 19). Only a character with one of these four W.P.s can make the weapon do Mega-Damage. A ribbon-thin, flexible sword that channels ambient P.P.E.: 2D6 M.D. per strike against M.D.C., supernatural and magic opponents. +1D6 M.D. at levels 4, 8 and 12.',
        NULL,
        '[{"level":2,"applies_when":"with a scholar''s sword","combat":{"strike":1}},{"level":3,"applies_when":"with a scholar''s sword","combat":{"parry":1}},{"level":5,"applies_when":"with a scholar''s sword","combat":{"strike":1}},{"level":6,"applies_when":"with a scholar''s sword","combat":{"parry":1}},{"level":9,"applies_when":"with a scholar''s sword","combat":{"parry":1}},{"level":10,"applies_when":"with a scholar''s sword","combat":{"strike":1}},{"level":12,"applies_when":"with a scholar''s sword","combat":{"parry":1}},{"level":15,"applies_when":"with a scholar''s sword","combat":{"strike":1,"parry":1}}]');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('Hand to Hand: Tai-Chi Ch''uan', 'Physical', 0, 0, '["rifts"]', 'import',
        'Rifts World Book 25: China 2 p.19-20',
        'Rifts China''s basic hand to hand (printed 19 lists it as Hand to Hand (Basic): Tai Chi): slow, flowing exercise that roughly a quarter of ordinary people and half the elderly of Rifts China practise. Also adds 2D6 to the permanent I.S.P. base at levels 6 and 15.',
        NULL,
        '[{"level":1,"combat":{"attacks_base":3,"roll":2}},{"level":2,"combat":{"strike":1,"parry":1,"disarm":1}},{"level":3,"combat":{"attacks":1}},{"level":4,"combat":{"initiative":1,"roll":2}},{"level":5,"combat":{"attacks":1}},{"level":6,"note":"Grab & Throw: 1D6 damage, the victim loses initiative and its next melee action. Add 2D6 to the permanent I.S.P. base."},{"level":7,"combat":{"strike":1,"parry":1,"pull_punch":1}},{"level":8,"note":"Open Hand Push: 1D6 damage, the victim loses initiative and its next two melee actions."},{"level":9,"combat":{"dodge":1,"roll":1,"attacks":1}},{"level":10,"combat":{"attacks":1}},{"level":11,"combat":{"parry":1,"disarm":1,"damage_bonus":2}},{"level":12,"combat":{"strike":1,"dodge":1}},{"level":13,"combat":{"roll":1,"pull_punch":1}},{"level":14,"combat":{"attacks":1}},{"level":15,"combat":{"disarm":1,"pull_punch":1},"note":"Add 2D6 to the permanent I.S.P. base."}]');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('Hand to Hand: Dog Boxing Kung Fu (Kuo-Ch''uan)', 'Physical', 0, 0, '["rifts"]', 'import',
        'Rifts World Book 25: China 2 p.20-21',
        'A secret, low-to-the-ground style that mimics a fighting dog, with snap kicks and backward sweeps. Snap kick and punch each do 1D6 S.D.C.',
        NULL,
        '[{"level":1,"combat":{"attacks_base":4,"strike":2,"roll":3,"pull_punch":2},"note":"Snap Kick 1D6 S.D.C., punch 1D6 S.D.C. Dog Boxing Side Flip: throw yourself half a body length aside in place of a dodge, without dodge bonuses; beat the attacker''s strike and it costs no action, fail and lose one action but automatically roll with the blow for half damage."},{"level":2,"combat":{"attacks":1}},{"level":3,"note":"Dog Yip Attack: select one additional Body Hardening Exercise (Demon Hunter exercises included). +1 to Side Flip."},{"level":4,"combat":{"strike":1},"note":"+1 more to strike with rear attacks (backward sweep, backhand strike). Critical strike on a natural 19-20."},{"level":5,"combat":{"attacks":1}},{"level":6,"note":"Wounded Paw & Whine: a feigned limp; while it holds the opponent is -1 to strike and the character +1 to strike or +2 to parry and dodge."},{"level":7,"combat":{"roll":2},"note":"Death blow on a natural 19-20."},{"level":8,"combat":{"attacks":1,"dodge":1}},{"level":9,"note":"Force Bark: everyone within 20 ft (6.1 m) saves vs pain (13+, P.E. bonus counts) or is knocked back 2D6 ft and loses one melee action."},{"level":10,"combat":{"strike":1},"note":"+1 to Side Flip."},{"level":11,"combat":{"attacks":1,"parry":1,"dodge":1}},{"level":12,"note":"Mad Dog Horror Growl: Horror Factor 16."},{"level":13,"combat":{"damage_bonus":1,"roll":1}},{"level":14,"combat":{"attacks":1}},{"level":15,"note":"+2 to Side Flip."}]');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('Hand to Hand: Drunken Style Kung Fu', 'Physical', 0, 0, '["rifts"]', 'import',
        'Rifts World Book 25: China 2 p.21-22',
        'A very difficult style that fakes drunken staggering to hide its attacks; the practitioner need not actually drink.',
        NULL,
        '[{"level":1,"combat":{"attacks_base":3,"roll":2},"note":"+2 to somersault, stagger, roll and backflip. Knockout/stun and critical strike on a natural 19-20; critical strike from behind. Foot Play: flick objects off the ground into the hands or kick them as projectiles. Controlled Staggering: dodge any attack the character can see without spending an action, at normal dodge bonuses."},{"level":2,"combat":{"dodge":2,"pull_punch":2}},{"level":3,"combat":{"strike":1,"initiative":1}},{"level":4,"note":"Faked Alcohol Sickness: Horror Factor 12 to those in immediate range; a failed save stuns, costing one melee action and initiative."},{"level":5,"combat":{"attacks":1}},{"level":6,"combat":{"strike":1},"note":"Knockout/stun on a natural 19-20."},{"level":7,"combat":{"disarm":2,"entangle":2}},{"level":8,"note":"Projectile Vomit: once an hour unprepared, up to three times if prepared with food beforehand. The victim saves vs H.F. 14 or loses initiative and two actions; a deliberate attempt at half strike bonuses is H.F. 16 and costs three actions. The victim''s combat bonuses against the character are halved for up to half an hour."},{"level":9,"combat":{"attacks":1}},{"level":10,"combat":{"roll":2,"pull_punch":1}},{"level":11,"note":"Joint Twisting: dislocate joints at will; slip handcuffs, rope or plastic bonds in 2D6 melee rounds, or a hold or pin in one melee round."},{"level":12,"combat":{"dodge":1,"strike":1}},{"level":13,"combat":{"roll":2,"pull_punch":1}},{"level":14,"combat":{"attacks":1}},{"level":15,"combat":{"damage_bonus":1},"note":"Knockout/stun on a natural 17 or better."}]');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('Hand to Hand: Eighteen Weapons Kung Fu (Shih Ba Ban Wu Yi)', 'Physical', 0, 0, '["rifts"]', 'import',
        'Rifts World Book 25: China 2 p.22-23',
        'A weapon-based style built on the classic eighteen Chinese weapons. It grants Weapon Proficiencies as it advances, picked from its own lists (printed 22): single W.P.s - Axe, Blowpipe, Blunt, Chain, Dartgun, Forked, Knife, Pole Arm, Shen Biau (rope dart), Spear, Staff, Large Sword, Short Sword, Whip, Slingshot, Small Thrown Weapons, Bow, Crossbow; matched paired weapons; and mismatched pairs (short sword and axe, large sword and knife, short and long sword, short sword and knife, forked and knife, chain and knife, chain and short sword, short sword and whip). The W.P. grants are picks the player makes and are stated here, not applied.',
        NULL,
        '[{"level":1,"combat":{"attacks_base":4,"strike":1,"roll":1,"parry":1,"dodge":1},"note":"Kung Fu Tap: a no-damage, pulled rap of the weapon with a loud crack (a called shot), Horror Factor 12 - a failed save sends the victim running; works only on opponents of levels 1-3. Select two W.P.s from the style''s list."},{"level":2,"combat":{"damage_bonus":2},"note":"Critical strike on a natural 19-20. Select two more W.P.s."},{"level":3,"combat":{"attacks":1},"note":"Select one more W.P."},{"level":4,"combat":{"strike":1,"disarm":1},"note":"Select one paired W.P."},{"level":5,"combat":{"parry":1,"dodge":1},"note":"Select two more W.P.s."},{"level":6,"combat":{"damage_bonus":1},"note":"Select one more W.P."},{"level":7,"combat":{"attacks":1},"note":"Select one paired W.P."},{"level":8,"combat":{"initiative":1,"disarm":1},"note":"Select two more W.P.s."},{"level":9,"combat":{"strike":1},"note":"Select one more W.P."},{"level":10,"combat":{"disarm":1},"note":"Select one paired W.P."},{"level":11,"combat":{"attacks":1},"note":"Select one more W.P."},{"level":12,"combat":{"damage_bonus":2},"note":"Select one more W.P."},{"level":13,"combat":{"strike":1},"note":"Critical strike on a natural 18 or better. Select one paired W.P."},{"level":14,"combat":{"initiative":1,"disarm":1},"note":"Select one more W.P."},{"level":15,"combat":{"attacks":1},"note":"Select one more W.P."}]');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('Hand to Hand: Jade Fan (Chi Hsuan Men)', 'Physical', 0, 0, '["rifts"]', 'import',
        'Rifts World Book 25: China 2 p.22-24',
        'White Jade Fan (printed 19''s name): a scholar''s fighting style using one or two fans. Fighting with a makeshift weapon instead is -1 strike, -2 parry, -2 damage; bare-handed, -2 strike, -4 parry, -4 damage. Closed fan thrust 1D8, open fan slash 1D6, thrown fan 1D4.',
        NULL,
        '[{"level":1,"combat":{"attacks_base":2,"roll":1},"note":"Closed fan thrust 1D8, open fan slash 1D6, thrown fan 1D4. Jade Fan Disarm: in place of an attack, loosen the enemy''s grip and twist the weapon away."},{"level":2,"note":"Critical strike on a natural 20."},{"level":3,"combat":{"disarm":2,"damage_bonus":2}},{"level":4,"combat":{"attacks":1}},{"level":5,"combat":{"roll":1},"note":"Critical strike on a natural 19-20."},{"level":6,"note":"Jade Fan Doubling: with a fan in each hand, use both at once - double damage on one target, strike two foes, or block with one and strike with the other."},{"level":7,"combat":{"damage_bonus":2,"parry":2}},{"level":8,"note":"Critical strike on a natural 17 or better."},{"level":9,"combat":{"roll":1,"disarm":1}},{"level":10,"note":"Falling Fan Trick: after two purely defensive rounds (+3 parry, +1 dodge, no attacks) the character vanishes at the start of the third, a sleight-of-hand escape."},{"level":11,"combat":{"attacks":1}},{"level":12,"note":"Critical strike on a natural 15 or better."},{"level":13,"combat":{"disarm":2}},{"level":14,"note":"Withering Flesh Attack: knocks the victim''s S.D.C. to zero without touching hit points (rolling with it takes 1D6 S.D.C. instead); against M.D.C. or supernatural beings, 1D6 M.D. per attack."},{"level":15,"combat":{"attacks":1}}]');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('Hand to Hand: Monkey Style Kung Fu (Tai Sing Pek Kwar)', 'Physical', 0, 0, '["rifts"]', 'import',
        'Rifts World Book 25: China 2 p.23-24',
        'An acrobatic style imitating a monkey; every practitioner masters backflips and somersaults and is an expert climber. Monkey Moves (printed 24), each usually a full melee round: Berserk Monkey (+2 attacks, +4 strike, +4 damage, +2 roll; -4 parry, no dodge), Blind Monkey (one attack only, +5 strike, critical on 12+), Monkey''s One Hand Climb (climb at full speed one-handed), Monkey Shriek (all within 12 ft save vs stun 12+ or lose initiative, one action and -1 to all combat), Proud Monkey (two attacks only, +2 strike and parry, +1D6 damage), Taunting Monkey (+5 initiative, +5 parry and dodge; the enraged foe''s attacks each cost two actions), Wood Monkey (a sprung trap: two simultaneous attacks at +6 strike, +4 damage each).',
        NULL,
        '[{"level":1,"combat":{"attacks_base":3,"parry":2,"dodge":2,"roll":3},"note":"Critical strike from behind. One Monkey Move of choice."},{"level":2,"combat":{"damage_bonus":1},"note":"+1 to leap, backflip and somersault."},{"level":3,"combat":{"attacks":1}},{"level":4,"note":"Add one Monkey Move."},{"level":5,"combat":{"parry":1,"dodge":1},"note":"+1 to leap, backflip and somersault."},{"level":6,"note":"Add one Monkey Move."},{"level":7,"combat":{"roll":1},"note":"Critical strike on a natural 19-20."},{"level":8,"note":"Add one Monkey Move."},{"level":9,"combat":{"attacks":1}},{"level":10,"combat":{"roll":2},"note":"Critical strike on a natural 18 or better."},{"level":11,"note":"Add one Monkey Move."},{"level":12,"combat":{"parry":1,"dodge":1},"note":"+2 to leap, backflip and somersault."},{"level":13,"note":"Add one Monkey Move."},{"level":14,"note":"Critical strike on a natural 17 or better."},{"level":15,"combat":{"pull_punch":2,"initiative":1}}]');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('Hand to Hand: Shao-Lin Kung Fu', 'Physical', 0, 0, '["rifts"]', 'import',
        'Rifts World Book 25: China 2 p.24-25',
        'The most widespread martial art of Rifts China, taught by the Shao-Lin temples. Its body hardening at levels 4, 9 and 13 adds S.D.C. and dice of P.S. and P.E., which are stated per level and not applied.',
        NULL,
        '[{"level":1,"combat":{"attacks_base":4,"roll":3,"strike":2,"parry":1,"dodge":1,"pull_punch":4},"note":"Dragon Power Punch 3D4, Tiger Kick 2D8, Leopard Hand Strike 2D4, Snake Snap Kick 1D10, Crane Elbow Strike 2D4."},{"level":2,"combat":{"initiative":2,"strike":1,"damage_bonus":2},"note":"Critical strike on a natural 19-20."},{"level":3,"combat":{"attacks":1}},{"level":4,"note":"Body Hardening Exercise: +10 S.D.C., +1D4 P.S., +1D4 P.E."},{"level":5,"combat":{"roll":1},"note":"Critical strike on a natural 18 or better."},{"level":6,"combat":{"initiative":2,"strike":1,"parry":1,"dodge":1,"damage_bonus":1}},{"level":7,"combat":{"attacks":1}},{"level":8,"combat":{"roll":1,"pull_punch":2},"note":"+1 to back flip and leap."},{"level":9,"note":"Body Hardening Exercise: +10 S.D.C., +1D6 P.S."},{"level":10,"combat":{"damage_bonus":2,"disarm":1},"note":"Critical strike on a natural 17 or better."},{"level":11,"combat":{"attacks":1}},{"level":12,"combat":{"strike":2,"parry":1,"dodge":1},"note":"+1D6 damage."},{"level":13,"note":"Body Hardening Exercise: +20 S.D.C., +1D6 P.E."},{"level":14,"combat":{"pull_punch":2,"strike":1},"note":"+1D6 damage."},{"level":15,"combat":{"attacks":1,"roll":2}}]');

SELECT 'China 2 adds 37 skills' AS assertion, count(*) AS got, 37 AS want
  FROM skills WHERE source_book LIKE 'Rifts World Book 25: China 2 p.%';

SELECT 'the seven styles each state starting attacks' AS assertion, count(*) AS got, 7 AS want
  FROM skills
 WHERE name LIKE 'Hand to Hand:%' AND source_book LIKE 'Rifts World Book 25: China 2 p.%'
   AND json_extract(level_bonuses, '$[0].combat.attacks_base') > 0;

SELECT 'every W.P. bonus here is conditional' AS assertion, count(*) AS got, 0 AS want
  FROM skills, json_each(skills.level_bonuses)
 WHERE skills.name LIKE 'W.P.%' AND skills.source_book LIKE 'Rifts World Book 25: China 2 p.%'
   AND json_extract(json_each.value, '$.combat') IS NOT NULL
   AND json_extract(json_each.value, '$.applies_when') IS NULL;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-a-china-2-skills.sql');
