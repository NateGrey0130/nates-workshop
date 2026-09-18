-- characters.kind: whether a character row is a PLAYER character or an NPC the
-- G.M. statted.
--
-- Phase 1 of the NPC / bestiary work, decided with Nate on 2026-09-17. A G.M.
-- wants "a 4th-level Brodkil raider, statted, now", and every piece of that
-- already exists for a player character - the 337 published classes, the dice
-- and level-up engine, the sheet, play mode, rest, the validator. An NPC is
-- therefore a `characters` row with this set to 'npc', owned by the campaign's
-- G.M., and every one of those paths works on it unchanged.
--
-- Rejected: a separate campaign_npcs table (it would duplicate ~40 columns and
-- need a second sheet renderer), and stat columns on `npcs` (the dossier has no
-- pools, skills, powers or combat shape - it is the NARRATIVE record, and
-- migration 071 links the two instead).
--
-- NO CHECK constraint, deliberately. The sheet and the validator read this by
-- name, as they read `skills[].type`, and a CHECK refuses a saved row rather
-- than a bad write. And a CHECK is expensive to change here: 058 rebuilt
-- sixteen tables to widen one on `campaigns`. The values are 'pc' and 'npc';
-- the API is what writes them.
--
-- WHAT THIS COLUMN DOES NOT DO ON ITS OWN: hide anything. Character reads are
-- open to any signed-in user by design (requireCharacter's read guard stops
-- after the existence check), so an NPC's stats are only G.M.-private once the
-- read path learns about `kind`. That is the next PR, and it lands BEFORE
-- anything can create a row with 'npc' in it.
ALTER TABLE characters ADD COLUMN kind TEXT NOT NULL DEFAULT 'pc';

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('070-character-kind.sql');
