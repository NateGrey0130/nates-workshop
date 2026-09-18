-- npcs.character_id: the statted sheet behind a dossier, when there is one.
--
-- Phase 1 of the NPC / bestiary work, with 070. A dossier (plan 16) is the
-- narrative record - name, faction, disposition, status, portrait, and every
-- journal entry that mentions them. A `characters` row with kind = 'npc' is the
-- mechanics - attributes, pools, skills, attacks. Nate's answer was to link the
-- two OPTIONALLY: a dossier with no stats is the normal case (the merchant in
-- Kingsdale), and a rolled bandit with no dossier is too (six of them are not
-- six people anyone will write about).
--
-- ON DELETE SET NULL, not CASCADE: deleting a sheet must not delete the dossier
-- and its journal backlinks, which are the table's memory of that person.
--
-- Not unique. Nothing here stops two dossiers pointing at one sheet, and
-- nothing needs to yet; the endpoint that writes it is where a rule would go.
ALTER TABLE npcs ADD COLUMN character_id INTEGER REFERENCES characters(id) ON DELETE SET NULL;

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('071-npc-character-link.sql');
