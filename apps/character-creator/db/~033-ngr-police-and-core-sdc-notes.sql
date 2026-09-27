-- Two follow-ups the #1466 cleanup (~029-class-vessel-notes.sql) left open:
-- the NGR Police's issued armour and tear gas, and every class note that
-- still described CORE_SDC_BY_CLASS as live.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~033-ngr-police-and-core-sdc-notes.sql
--
-- == ngr-police (Rifts World Book 5: Triax and the NGR) ==
--
-- Printed 174, read off a 200 dpi render of the scan: "Choice of T-10 or
-- T-12 (light grey color and no medic symbols) body armor" and "two tear gas
-- grenades". The note said the grenades had no catalog row; production holds
-- `triax-tear-gas-grenade` (Tear Gas Grenade, Triax p.149-150), and both
-- armour rows, `t-10-infantry-cyclops-body-armor` and
-- `t-12-field-medic-body-armor` (Triax p.35-36), all checked --remote on
-- 2026-09-27. So equipment_starting grants two grenades and a choose: 1 of
-- the two armours, the same shape as the class's existing Flanker choice,
-- and the note and GM Notes say so. The handcuffs, billy club and the
-- weapons of choice are unchanged and stay in the body.
--
-- == CORE_SDC_BY_CLASS ==
--
-- That map in js/compose.js was removed on 2026-09-25 by
-- ~001-men-of-arms-frontmatter.sql: each class carries its own `men_of_arms`
-- line now. Production searched on 2026-09-27 for
-- instr(markdown, 'CORE_SDC_BY_CLASS') > 0 returned 49 classes, and every one
-- described the map in the present tense - "needs a CORE_SDC_BY_CLASS entry",
-- "reaches it via CORE_SDC_BY_CLASS", "no CORE_SDC_BY_CLASS entry". Each is
-- rewritten to name the class's own line, with its value read off that
-- class's frontmatter --remote:
--
--   - a class stating neither sdc_base nor mdc_base now says it carries
--     `men_of_arms: true` or `false`, and that this was a CORE_SDC_BY_CLASS
--     entry until 2026-09-25;
--   - a class stating an sdc_base or mdc_base (the natural M.D.C. races, the
--     Cosmo-Knights, the Promethean, the Plant Shaman, the Wendigo, the
--     Greater Cyclops) now says it needs no `men_of_arms` line, which is the
--     rule class-import states;
--   - the Pleasurer's past-tense "was added to CORE_SDC_BY_CLASS" is kept and
--     given the line that replaced it.
--
-- The Salvage Expert (Rifts World Book 7: Underseas) is one of the 49; it was
-- the one the #1466 report named.
--
-- Every UPDATE is keyed on class_id and guarded on the text it replaces, so a
-- re-run is a no-op.

UPDATE imported_classes SET markdown = replace(markdown, '  - { item_id: "dress-uniform", qty: 1 }' || char(10) || '  - { choose: 1, label: "X-60 Flanker or hovercycle"',
  '  - { item_id: "dress-uniform", qty: 1 }' || char(10) || '  - { item_id: "triax-tear-gas-grenade", qty: 2 }' || char(10) || '  - { choose: 1, label: "T-10 or T-12 body armour", qty: 1, from: ["t-10-infantry-cyclops-body-armor", "t-12-field-medic-body-armor"] }' || char(10) || '  - { choose: 1, label: "X-60 Flanker or hovercycle"')
  WHERE class_id = 'ngr-police' AND instr(markdown, '  - { item_id: "dress-uniform", qty: 1 }' || char(10) || '  - { choose: 1, label: "X-60 Flanker or hovercycle"') > 0;

UPDATE imported_classes SET markdown = replace(markdown, '  - Six issued items are choices the book does not resolve or have no catalog' || char(10) || '    row, and none is stubbed: a choice of T-10 or T-12 body armour, an automatic' || char(10) || '    pistol of choice, an energy pistol of choice, an energy rifle of choice, a' || char(10) || '    gun holster of choice, and two pairs of handcuffs. The billy club/riot club' || char(10) || '    (1D6 S.D.C.) and the two tear gas grenades have no rows either. In the body.' || char(10) || '',
  '  - Four issued items are choices the book does not resolve, and none is' || char(10) || '    stubbed: an automatic pistol, an energy pistol, an energy rifle and a gun' || char(10) || '    holster, each of choice. The billy club/riot club (1D6 S.D.C.) has no row,' || char(10) || '    and the two pairs of handcuffs are not granted. All are in the body.' || char(10) || '  - THE T-10 OR T-12 BODY ARMOUR AND THE TWO TEAR GAS GRENADES ARE IN' || char(10) || '    equipment_starting since 2026-09-27 (~033-ngr-police-and-core-sdc-notes.sql).' || char(10) || '    Printed 174 issues a "Choice of T-10 or T-12" body armour, stored as a' || char(10) || '    choice of `t-10-infantry-cyclops-body-armor` and `t-12-field-medic-body-armor`' || char(10) || '    (printed 35-36); the T-12 issued in light grey with no medic symbols is in' || char(10) || '    the body. It issues "two tear gas grenades", stored as two of' || char(10) || '    `triax-tear-gas-grenade` (printed 149-150). Until then this note said the' || char(10) || '    grenades had no row and left the armour choice to the body.' || char(10) || '')
  WHERE class_id = 'ngr-police' AND instr(markdown, '  - Six issued items are choices the book does not resolve or have no catalog' || char(10) || '    row, and none is stubbed: a choice of T-10 or T-12 body armour, an automatic' || char(10) || '    pistol of choice, an energy pistol of choice, an energy rifle of choice, a' || char(10) || '    gun holster of choice, and two pairs of handcuffs. The billy club/riot club' || char(10) || '    (1D6 S.D.C.) and the two tear gas grenades have no rows either. In the body.' || char(10) || '') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'Issued alongside the stored equipment, and not given catalog rows: a choice of T-10 or T-12 body armour (the T-12 in light grey with no medic symbols), an automatic pistol',
  'Of the stored equipment, the T-12 body armour, if chosen, comes in light grey with no medic symbols. Issued alongside it, and not given catalog rows: an automatic pistol')
  WHERE class_id = 'ngr-police' AND instr(markdown, 'Issued alongside the stored equipment, and not given catalog rows: a choice of T-10 or T-12 body armour (the T-12 in light grey with no medic symbols), an automatic pistol') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'a billy club or riot club doing 1D6 S.D.C., and two tear gas grenades. Also',
  'and a billy club or riot club doing 1D6 S.D.C. Also')
  WHERE class_id = 'ngr-police' AND instr(markdown, 'a billy club or riot club doing 1D6 S.D.C., and two tear gas grenades. Also') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'class takes its 1D6 from CORE_SDC_BY_CLASS in js/compose.js - 1D6 rather',
  'class takes its 1D6 from its `men_of_arms: false` line (until 2026-09-25 a CORE_SDC_BY_CLASS entry in js/compose.js) - 1D6 rather')
  WHERE class_id = 'rifts-priest' AND instr(markdown, 'class takes its 1D6 from CORE_SDC_BY_CLASS in js/compose.js - 1D6 rather') > 0;

UPDATE imported_classes SET markdown = replace(markdown, '     CORE_SDC_BY_CLASS in js/compose.js. Filed at 3D6,',
  '     its `men_of_arms: true` line (until 2026-09-25 a CORE_SDC_BY_CLASS entry in js/compose.js). Filed at 3D6,')
  WHERE class_id = 'berserker' AND instr(markdown, '     CORE_SDC_BY_CLASS in js/compose.js. Filed at 3D6,') > 0;

UPDATE imported_classes SET markdown = replace(markdown, '     CORE_SDC_BY_CLASS entry is required.',
  '     `men_of_arms` line is required.')
  WHERE class_id = 'greater-cyclops' AND instr(markdown, '     CORE_SDC_BY_CLASS entry is required.') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'so it needs a CORE_SDC_BY_CLASS entry, at 1D6 because',
  'so it carries `men_of_arms: false` (until 2026-09-25 a CORE_SDC_BY_CLASS entry in js/compose.js), 1D6 because')
  WHERE class_id = 'gambler' AND instr(markdown, 'so it needs a CORE_SDC_BY_CLASS entry, at 1D6 because') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'so it needs a CORE_SDC_BY_CLASS entry, at 1D6:',
  'so it carries `men_of_arms: false` (until 2026-09-25 a CORE_SDC_BY_CLASS entry in js/compose.js), 1D6:')
  WHERE class_id = 'juicer-wannabe' AND instr(markdown, 'so it needs a CORE_SDC_BY_CLASS entry, at 1D6:') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'falls through to the core rule via CORE_SDC_BY_CLASS; hit points',
  'falls through to the core rule at 1D6 via its `men_of_arms: false` line (until 2026-09-25 a CORE_SDC_BY_CLASS entry in js/compose.js); hit points')
  WHERE class_id = 'noro' AND instr(markdown, 'falls through to the core rule via CORE_SDC_BY_CLASS; hit points') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'reaches it via CORE_SDC_BY_CLASS. 3D6 rather than 1D6, on the psi-stalker' || char(10) || '    precedent already in that table',
  'reaches it via its `men_of_arms: true` line (until 2026-09-25 a CORE_SDC_BY_CLASS entry in js/compose.js). 3D6 rather than 1D6, on the psi-stalker' || char(10) || '    precedent')
  WHERE class_id = 'noro-mystic-warrior' AND instr(markdown, 'reaches it via CORE_SDC_BY_CLASS. 3D6 rather than 1D6, on the psi-stalker' || char(10) || '    precedent already in that table') > 0;

UPDATE imported_classes SET markdown = replace(markdown, '    CORE_SDC_BY_CLASS, and the 30 lands on top.',
  '    its `men_of_arms: false` line (until 2026-09-25 a CORE_SDC_BY_CLASS entry in js/compose.js), and the 30 lands on top.')
  WHERE class_id = 'space-wolfen' AND instr(markdown, '    CORE_SDC_BY_CLASS, and the 30 lands on top.') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'S.D.C. and no CORE_SDC_BY_CLASS entry.',
  'S.D.C. and no `men_of_arms` line.')
  WHERE class_id = 'catyr' AND instr(markdown, 'S.D.C. and no CORE_SDC_BY_CLASS entry.') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'S.D.C. and no CORE_SDC_BY_CLASS entry.',
  'S.D.C. and no `men_of_arms` line.')
  WHERE class_id = 'seljuk' AND instr(markdown, 'S.D.C. and no CORE_SDC_BY_CLASS entry.') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'S.D.C. and no CORE_SDC_BY_CLASS entry.',
  'S.D.C. and no `men_of_arms` line.')
  WHERE class_id = 'kreeghor' AND instr(markdown, 'S.D.C. and no CORE_SDC_BY_CLASS entry.') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'S.D.C. and no CORE_SDC_BY_CLASS entry.',
  'S.D.C. and no `men_of_arms` line.')
  WHERE class_id = 'machine-people' AND instr(markdown, 'S.D.C. and no CORE_SDC_BY_CLASS entry.') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'no S.D.C. and no CORE_SDC_BY_CLASS' || char(10) || '    entry.',
  'no S.D.C. and no `men_of_arms`' || char(10) || '    line.')
  WHERE class_id = 'silhouette' AND instr(markdown, 'no S.D.C. and no CORE_SDC_BY_CLASS' || char(10) || '    entry.') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'no S.D.C. and no CORE_SDC_BY_CLASS' || char(10) || '    entry.',
  'no S.D.C. and no `men_of_arms`' || char(10) || '    line.')
  WHERE class_id = 'draconid' AND instr(markdown, 'no S.D.C. and no CORE_SDC_BY_CLASS' || char(10) || '    entry.') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'no S.D.C. and no CORE_SDC_BY_CLASS' || char(10) || '    entry.',
  'no S.D.C. and no `men_of_arms`' || char(10) || '    line.')
  WHERE class_id = 'phantom' AND instr(markdown, 'no S.D.C. and no CORE_SDC_BY_CLASS' || char(10) || '    entry.') > 0;

UPDATE imported_classes SET markdown = replace(markdown, '' || char(10) || '    CORE_SDC_BY_CLASS entry.',
  '' || char(10) || '    `men_of_arms` line.')
  WHERE class_id = 'naruni-repo-bot' AND instr(markdown, '' || char(10) || '    CORE_SDC_BY_CLASS entry.') > 0;

UPDATE imported_classes SET markdown = replace(markdown, '' || char(10) || '    CORE_SDC_BY_CLASS entry.',
  '' || char(10) || '    `men_of_arms` line.')
  WHERE class_id = 'vacuum-wasp' AND instr(markdown, '' || char(10) || '    CORE_SDC_BY_CLASS entry.') > 0;

UPDATE imported_classes SET markdown = replace(markdown, '' || char(10) || '    CORE_SDC_BY_CLASS entry.',
  '' || char(10) || '    `men_of_arms` line.')
  WHERE class_id = 'termite-engineer' AND instr(markdown, '' || char(10) || '    CORE_SDC_BY_CLASS entry.') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'reaches it via CORE_SDC_BY_CLASS at 3D6 -',
  'reaches it at 3D6 via its `men_of_arms: true` line (until 2026-09-25 a CORE_SDC_BY_CLASS entry in js/compose.js) -')
  WHERE class_id = 'imperial-legionnaire' AND instr(markdown, 'reaches it via CORE_SDC_BY_CLASS at 3D6 -') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'reaches it via CORE_SDC_BY_CLASS at 1D6 -',
  'reaches it at 1D6 via its `men_of_arms: false` line (until 2026-09-25 a CORE_SDC_BY_CLASS entry in js/compose.js) -')
  WHERE class_id = 'imperial-security-agent' AND instr(markdown, 'reaches it via CORE_SDC_BY_CLASS at 1D6 -') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'reaches it via CORE_SDC_BY_CLASS at 3D6 -',
  'reaches it at 3D6 via its `men_of_arms: true` line (until 2026-09-25 a CORE_SDC_BY_CLASS entry in js/compose.js) -')
  WHERE class_id = 'freedom-fighter' AND instr(markdown, 'reaches it via CORE_SDC_BY_CLASS at 3D6 -') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'reaches it via CORE_SDC_BY_CLASS at 1D6 -',
  'reaches it at 1D6 via its `men_of_arms: false` line (until 2026-09-25 a CORE_SDC_BY_CLASS entry in js/compose.js) -')
  WHERE class_id = 'spacer' AND instr(markdown, 'reaches it via CORE_SDC_BY_CLASS at 1D6 -') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'reaches it via CORE_SDC_BY_CLASS at 3D6 -',
  'reaches it at 3D6 via its `men_of_arms: true` line (until 2026-09-25 a CORE_SDC_BY_CLASS entry in js/compose.js) -')
  WHERE class_id = 'galactic-tracer' AND instr(markdown, 'reaches it via CORE_SDC_BY_CLASS at 3D6 -') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'reaches it via CORE_SDC_BY_CLASS at 3D6 -',
  'reaches it at 3D6 via its `men_of_arms: true` line (until 2026-09-25 a CORE_SDC_BY_CLASS entry in js/compose.js) -')
  WHERE class_id = 'space-pirate' AND instr(markdown, 'reaches it via CORE_SDC_BY_CLASS at 3D6 -') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'reaches it via CORE_SDC_BY_CLASS at 1D6 -',
  'reaches it at 1D6 via its `men_of_arms: false` line (until 2026-09-25 a CORE_SDC_BY_CLASS entry in js/compose.js) -')
  WHERE class_id = 'runner' AND instr(markdown, 'reaches it via CORE_SDC_BY_CLASS at 1D6 -') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'reaches it via CORE_SDC_BY_CLASS at 1D6 -',
  'reaches it at 1D6 via its `men_of_arms: false` line (until 2026-09-25 a CORE_SDC_BY_CLASS entry in js/compose.js) -')
  WHERE class_id = 'colonist' AND instr(markdown, 'reaches it via CORE_SDC_BY_CLASS at 1D6 -') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'was added to CORE_SDC_BY_CLASS in js/compose.js, which',
  'was added to CORE_SDC_BY_CLASS in js/compose.js; since 2026-09-25 it is the class''s own `men_of_arms: false` line, which')
  WHERE class_id = 'pleasurer' AND instr(markdown, 'was added to CORE_SDC_BY_CLASS in js/compose.js, which') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'this class needs no CORE_SDC_BY_CLASS entry.',
  'this class needs no `men_of_arms` line.')
  WHERE class_id = 'first-stage-promethean' AND instr(markdown, 'this class needs no CORE_SDC_BY_CLASS entry.') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'THIS CLASS NEEDS NO `CORE_SDC_BY_CLASS` ENTRY.',
  'THIS CLASS NEEDS NO `men_of_arms` LINE.')
  WHERE class_id = 'cosmo-knight' AND instr(markdown, 'THIS CLASS NEEDS NO `CORE_SDC_BY_CLASS` ENTRY.') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'needs an' || char(10) || '    entry does not reach it.',
  'needs a' || char(10) || '    `men_of_arms` line does not reach it.')
  WHERE class_id = 'cosmo-knight' AND instr(markdown, 'needs an' || char(10) || '    entry does not reach it.') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'THIS CLASS NEEDS NO `CORE_SDC_BY_CLASS` ENTRY:',
  'THIS CLASS NEEDS NO `men_of_arms` LINE:')
  WHERE class_id = 'fallen-cosmo-knight' AND instr(markdown, 'THIS CLASS NEEDS NO `CORE_SDC_BY_CLASS` ENTRY:') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'entered in `CORE_SDC_BY_CLASS`:',
  'stated as `men_of_arms: false` (until 2026-09-25 a `CORE_SDC_BY_CLASS` entry in js/compose.js):')
  WHERE class_id = 'gypsy-gifted' AND instr(markdown, 'entered in `CORE_SDC_BY_CLASS`:') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'entered in `CORE_SDC_BY_CLASS`:',
  'stated as `men_of_arms: false` (until 2026-09-25 a `CORE_SDC_BY_CLASS` entry in js/compose.js):')
  WHERE class_id = 'gypsy-seer' AND instr(markdown, 'entered in `CORE_SDC_BY_CLASS`:') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'entered in `CORE_SDC_BY_CLASS`:',
  'stated as `men_of_arms: false` (until 2026-09-25 a `CORE_SDC_BY_CLASS` entry in js/compose.js):')
  WHERE class_id = 'gypsy-wizard-thief' AND instr(markdown, 'entered in `CORE_SDC_BY_CLASS`:') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'entered in `CORE_SDC_BY_CLASS`.',
  'stated as `men_of_arms: false` (until 2026-09-25 a `CORE_SDC_BY_CLASS` entry in js/compose.js).')
  WHERE class_id = 'gypsy-thief' AND instr(markdown, 'entered in `CORE_SDC_BY_CLASS`.') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'so this class needs a `CORE_SDC_BY_CLASS`' || char(10) || '    entry in `js/compose.js` or the smoke test fails it.',
  'so this class carries `men_of_arms: false`' || char(10) || '    (until 2026-09-25 a `CORE_SDC_BY_CLASS` entry in `js/compose.js`), or the smoke test fails it.')
  WHERE class_id = 'sea-inquisitor' AND instr(markdown, 'so this class needs a `CORE_SDC_BY_CLASS`' || char(10) || '    entry in `js/compose.js` or the smoke test fails it.') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'so it needs a `CORE_SDC_BY_CLASS` entry.',
  'so it carries `men_of_arms: false` (until 2026-09-25 a `CORE_SDC_BY_CLASS` entry in js/compose.js).')
  WHERE class_id = 'whale-singer' AND instr(markdown, 'so it needs a `CORE_SDC_BY_CLASS` entry.') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'so it needs a `CORE_SDC_BY_CLASS` entry.',
  'so it carries `men_of_arms: false` (until 2026-09-25 a `CORE_SDC_BY_CLASS` entry in js/compose.js).')
  WHERE class_id = 'ocean-wizard' AND instr(markdown, 'so it needs a `CORE_SDC_BY_CLASS` entry.') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'so it needs a `CORE_SDC_BY_CLASS` entry.',
  'so it carries `men_of_arms: false` (until 2026-09-25 a `CORE_SDC_BY_CLASS` entry in js/compose.js).')
  WHERE class_id = 'sea-druid' AND instr(markdown, 'so it needs a `CORE_SDC_BY_CLASS` entry.') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'so it needs a `CORE_SDC_BY_CLASS` entry.',
  'so it carries `men_of_arms: true` (until 2026-09-25 a `CORE_SDC_BY_CLASS` entry in js/compose.js).')
  WHERE class_id = 'tritonian-sea-wolf' AND instr(markdown, 'so it needs a `CORE_SDC_BY_CLASS` entry.') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'so it needs a `CORE_SDC_BY_CLASS` entry.',
  'so it carries `men_of_arms: false` (until 2026-09-25 a `CORE_SDC_BY_CLASS` entry in js/compose.js).')
  WHERE class_id = 'tritonian-scientist' AND instr(markdown, 'so it needs a `CORE_SDC_BY_CLASS` entry.') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'so it needs a `CORE_SDC_BY_CLASS` entry.',
  'so it carries `men_of_arms: true` (until 2026-09-25 a `CORE_SDC_BY_CLASS` entry in js/compose.js).')
  WHERE class_id = 'navy-seaman' AND instr(markdown, 'so it needs a `CORE_SDC_BY_CLASS` entry.') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'so it needs a `CORE_SDC_BY_CLASS` entry.',
  'so it carries `men_of_arms: true` (until 2026-09-25 a `CORE_SDC_BY_CLASS` entry in js/compose.js).')
  WHERE class_id = 'marine' AND instr(markdown, 'so it needs a `CORE_SDC_BY_CLASS` entry.') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'so it needs a `CORE_SDC_BY_CLASS` entry.',
  'so it carries `men_of_arms: false` (until 2026-09-25 a `CORE_SDC_BY_CLASS` entry in js/compose.js).')
  WHERE class_id = 'salvage-expert' AND instr(markdown, 'so it needs a `CORE_SDC_BY_CLASS` entry.') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'so this class needs no CORE_SDC_BY_CLASS entry.',
  'so this class needs no `men_of_arms` line.')
  WHERE class_id = 'plant-shaman' AND instr(markdown, 'so this class needs no CORE_SDC_BY_CLASS entry.') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'so no CORE_SDC_BY_CLASS entry is needed.',
  'so no `men_of_arms` line is needed.')
  WHERE class_id = 'wendigo' AND instr(markdown, 'so no CORE_SDC_BY_CLASS entry is needed.') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'since CORE_SDC_BY_CLASS gives a man of arms 3D6 where',
  'since its own `men_of_arms: true` line gives a man of arms 3D6 (until 2026-09-25 a CORE_SDC_BY_CLASS entry in js/compose.js) where')
  WHERE class_id = 'slayer-russian' AND instr(markdown, 'since CORE_SDC_BY_CLASS gives a man of arms 3D6 where') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'sets its S.D.C. to 3D6 through CORE_SDC_BY_CLASS, where',
  'sets its S.D.C. to 3D6 through its `men_of_arms: true` line (until 2026-09-25 a CORE_SDC_BY_CLASS entry in js/compose.js), where')
  WHERE class_id = 'gypsy-enforcer' AND instr(markdown, 'sets its S.D.C. to 3D6 through CORE_SDC_BY_CLASS, where') > 0;

UPDATE imported_classes SET markdown = replace(markdown, '    needs a CORE_SDC_BY_CLASS entry, 1D6 as a non-man-of-arms.',
  '    carries `men_of_arms: false` (until 2026-09-25 a CORE_SDC_BY_CLASS entry in js/compose.js), 1D6 as a non-man-of-arms.')
  WHERE class_id = 'knight-of-the-white-rose' AND instr(markdown, '    needs a CORE_SDC_BY_CLASS entry, 1D6 as a non-man-of-arms.') > 0;

UPDATE imported_classes SET markdown = replace(markdown, '    needs a CORE_SDC_BY_CLASS entry (3D6).',
  '    carries `men_of_arms: true` (until 2026-09-25 a CORE_SDC_BY_CLASS entry in js/compose.js), 3D6.')
  WHERE class_id = 'squire-of-the-white-rose' AND instr(markdown, '    needs a CORE_SDC_BY_CLASS entry (3D6).') > 0;

-- == READ-BACKS ==

SELECT 'each of the 49 classes names its own men_of_arms line, not the map' AS assertion, count(*) AS got, 49 AS want
  FROM imported_classes
  WHERE class_id IN ('rifts-priest', 'berserker', 'greater-cyclops', 'gambler',
                   'juicer-wannabe', 'noro', 'noro-mystic-warrior', 'space-wolfen',
                   'catyr', 'seljuk', 'kreeghor', 'machine-people',
                   'silhouette', 'imperial-legionnaire', 'imperial-security-agent', 'freedom-fighter',
                   'spacer', 'galactic-tracer', 'space-pirate', 'runner',
                   'colonist', 'draconid', 'phantom', 'naruni-repo-bot',
                   'pleasurer', 'vacuum-wasp', 'termite-engineer', 'first-stage-promethean',
                   'cosmo-knight', 'fallen-cosmo-knight', 'gypsy-gifted', 'gypsy-seer',
                   'gypsy-thief', 'gypsy-wizard-thief', 'sea-inquisitor', 'whale-singer',
                   'ocean-wizard', 'sea-druid', 'tritonian-sea-wolf', 'tritonian-scientist',
                   'navy-seaman', 'marine', 'salvage-expert', 'plant-shaman',
                   'wendigo', 'slayer-russian', 'gypsy-enforcer', 'knight-of-the-white-rose',
                   'squire-of-the-white-rose')
    AND instr(markdown, '`men_of_arms') > 0;

SELECT 'ngr-police grants two tear gas grenades and a T-10 or T-12 choice' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
  WHERE class_id = 'ngr-police'
    AND instr(markdown, '{ item_id: "triax-tear-gas-grenade", qty: 2 }') > 0
    AND instr(markdown, 'from: ["t-10-infantry-cyclops-body-armor", "t-12-field-medic-body-armor"]') > 0
    AND instr(markdown, 'TWO TEAR GAS GRENADES ARE IN') > 0
    AND instr(markdown, 'the T-12 body armour, if chosen,') > 0
    AND instr(markdown, 'two tear gas grenades have no rows') = 0
    AND instr(markdown, 'S.D.C., and two tear gas grenades. Also') = 0;

SELECT 'the three gear rows ngr-police now names exist' AS assertion, count(*) AS got, 3 AS want
  FROM gear
  WHERE slug IN ('triax-tear-gas-grenade', 't-10-infantry-cyclops-body-armor', 't-12-field-medic-body-armor');

SELECT 'no class describes CORE_SDC_BY_CLASS as live' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
  WHERE instr(markdown, 'needs a CORE_SDC_BY_CLASS') > 0
     OR instr(markdown, 'needs a `CORE_SDC_BY_CLASS`') > 0
     OR instr(markdown, 'via CORE_SDC_BY_CLASS') > 0
     OR instr(markdown, 'no CORE_SDC_BY_CLASS') > 0
     OR instr(markdown, 'NO `CORE_SDC_BY_CLASS`') > 0
     OR instr(markdown, 'entered in `CORE_SDC_BY_CLASS`') > 0
     OR instr(markdown, 'through CORE_SDC_BY_CLASS') > 0
     OR instr(markdown, 'CORE_SDC_BY_CLASS gives') > 0
     OR instr(markdown, 'from CORE_SDC_BY_CLASS') > 0
     OR instr(markdown, 'applies through' || char(10) || '     CORE_SDC_BY_CLASS') > 0
     OR instr(markdown, '    CORE_SDC_BY_CLASS entry.') > 0
     OR instr(markdown, '    CORE_SDC_BY_CLASS, and') > 0
     OR instr(markdown, 'needs an' || char(10) || '    entry does not reach it') > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~033-ngr-police-and-core-sdc-notes.sql');
