-- stat_attacks: the attacks a printed stat block lists - "Power Punch 2D6
-- M.D.", "Bite 1D6 M.D.", "Plasma rifle 6D6 M.D., 2000 ft" - one row each.
--
-- ONE table for two owners, decided with Nate on 2026-09-17: the named NPCs in
-- `notable_npcs` (migration 072) now, and the species in `creatures` (Phase 3)
-- later. Two tables doing the same job would be two importers and two
-- renderers for one shape.
--
-- (owner_kind, owner_slug) names the owner, with NO foreign key - the
-- precedent is gear.vehicle_slug (migration 053): a pointer to a row a later
-- session has not imported yet is inert rather than broken, which is what lets
-- this table land before `creatures` exists at all. owner_kind is free text,
-- 'notable_npc' or 'creature' by convention, for the reason 070 gives against
-- a CHECK.
--
-- UNIQUE per owner and attack name, so a data script can INSERT OR IGNORE and
-- be re-run. `damage` is TEXT because books print "2D6 M.D. per blast, 1D4x10
-- on a power punch"; `is_mega_damage` is structured for gear's reason - S.D.C.
-- against M.D.C. is the distinction that matters most, and reading it back out
-- of a damage string is error-prone.
CREATE TABLE IF NOT EXISTS stat_attacks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  owner_kind TEXT NOT NULL,
  owner_slug TEXT NOT NULL,
  name TEXT NOT NULL,
  damage TEXT,
  is_mega_damage INTEGER NOT NULL DEFAULT 0,
  range TEXT,
  note TEXT,
  sort INTEGER NOT NULL DEFAULT 0,
  UNIQUE (owner_kind, owner_slug, name)
);
CREATE INDEX IF NOT EXISTS idx_stat_attacks_owner ON stat_attacks (owner_kind, owner_slug);

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('073-stat-attacks.sql');
