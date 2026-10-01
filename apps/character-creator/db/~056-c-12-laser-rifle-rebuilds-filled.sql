-- A rebuild from the repo left c-12-laser-rifle as an empty stub; production
-- holds the filled row. This writes production's values where the stub is.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local "apps/character-creator/db/~056-c-12-laser-rifle-rebuilds-filled.sql"
--
-- THE MECHANISM. add-dog-boy-class.sql creates the slug as a stub.
-- retire-orphan-gear-stubs.sql deletes it only while no class names it, and
-- zzz-resolve-choice-group-gear.sql then inserts the filled row with INSERT OR
-- IGNORE. On 2026-10-01 three Lone Star classes began naming the slug
-- (tokanii, mutant-rat, mutant-bat), so in a rebuild the stub is no longer an
-- orphan, survives, and the filled insert is ignored. Production was never
-- rebuilt and is right. Found by scripts/repo-vs-live.mjs --offenders:
-- 12 fields on this one row, and nothing else.
--
-- PRODUCTION WINS (BOOK-INGEST-AUDIT F105): every value below was read from
-- production on 2026-10-01. Guarded on the stub description, so against
-- production it changes nothing.
--
-- Sorts after zzz-resolve-choice-group-gear.sql, the file it finishes.

UPDATE gear
   SET name = 'C-12 Heavy Assault Laser Rifle',
       category = 'weapon',
       weight_lbs = 7,
       cost = 20000,
       cost_note = 'Black market 20,000 credits',
       damage = 'Setting One: 2D6 M.D. single shot; Setting Two (burst): 6D6 M.D.; Setting Three (S.D.C.): 6D6 S.D.C.',
       is_mega_damage = 1,
       range = '2000 feet (610 m)',
       payload = '20 M.D. blasts from a standard E-Clip or 30 from a long E-Clip, plus another 30 from an E-Clip canister; six S.D.C. shots equal one M.D. blast',
       rate_of_fire = 'Single shot or a burst of three; each blast or burst counts as one melee attack',
       description = 'The standard Coalition infantry weapon until 105 P.A. and still a favorite of Commandos and Special Ops - a sturdy, reliable rifle that survives a great amount of combat abuse without mechanical failure. Three settings, one S.D.C. and two M.D.C. Comes standard with a passive nightvision scope and laser targeting (+1 to strike on an Aimed shot).',
       source_book = 'Rifts Ultimate Edition p.257-258'
 WHERE slug = 'c-12-laser-rifle' AND description LIKE 'STUB%';

-- Read the result back.
SELECT 'c-12-laser-rifle is the filled row' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE slug = 'c-12-laser-rifle' AND name = 'C-12 Heavy Assault Laser Rifle' AND is_mega_damage = 1 AND description NOT LIKE 'STUB%';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~056-c-12-laser-rifle-rebuilds-filled.sql');
