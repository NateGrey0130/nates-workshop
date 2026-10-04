-- Rifts World Book 7: Underseas - its bestiary and its notable NPCs.
-- 1 creatures (migration 074) and 0 notable NPCs (migration 072),
-- with their attacks in stat_attacks (migration 073).
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~080-underseas-ship-dreamers.sql
--
-- Written by scripts/bestiary-sql.mjs from 1 worker file(s). Every
-- creature row passes creatureFormulaGaps, every value is printable ASCII,
-- and an 8-word shingle check of the prose fields against the book's cached text finds no copied run.

INSERT INTO creatures (slug, name, category, system, playable, alignment, attributes, hp, sdc, mdc, ppe, isp, pools_note, ar, horror_factor, combat, bonuses_note, skills_note, natural_abilities, magic, psionics, size, weight, life_span, habitat, allies, enemies, occ_note, description, source_book) VALUES
('ship-dreamers', 'Ship Dreamers', 'alien humanoid', 'rifts', 0, 'Aberrant evil.', NULL, NULL, NULL, '3D6x10', '3D6x100', '6D6x100', 'Attributes are printed as ''Unknown!'', so none are stored. Hit Points reads only ''Mega-damage creature''. The I.S.P. figure is the entry''s ''Latent Psychic Energy in I.S.P.'', not a pool the Dreamer is shown spending: its psionics are listed as unknown. Bio-regenerates 1D4x10 per hour.', NULL, 10, '{"attacks":2}', 'Horror Factor is 10, rising to 19 when attacking or being probed. Two attacks per melee round, by magic and in self-defense only. +6 to save vs magic. Impervious to psionic attack and probes, cold, heat, fire, poison, disease and horror factor. A psychic who probes one must save vs psionic attack or suffer a brain aneurysm (death or a vegetative state, usually permanent).', 'O.C.C. skills, related skills, secondary skills, equipment, money and cybernetics are all printed as not applicable.', 'Sits cross-legged in a permanent trance, hovering a couple of feet off the deck or the water, eyes shut and silent; takes no food, drink or sleep, feeding on ambient psychic energy; shrugs off psionics, temperature extremes, fire, poison and disease; heals 1D4x10 an hour. When threatened a large mystic eye forms over its head and casts spells in its defense. Ten Dreamers together make one large or two small Dream Ships a year, or instead restore up to ten ships to new condition, or turn out 1000 sleds, scooters and magic weapons, or 100 of either type of combat drone.', 'Equal to a 1D4+10 level wizard. Knows all conventional spell magic, levels 1-13 (the entry points to Rifts RPG page 166).', 'Unknown. Impervious to all psionic attacks and probes, draws on the psionic energy around it, and is psionically linked to other Ship Dreamers.', 'Standard for horune; may look smaller because it is always seated', 'Thin for horune; about half normal weight', '770 years; some have lived as long as 1100', 'Aboard ships scattered through the horune pirate fleets', 'The horune people, for whom alone they will build ships', NULL, NULL, 'The one horune in a thousand born a Ship Dreamer: a mute, motionless alien mystic whose only acts are dreaming the horune Dream Ships into being and defending itself by magic. It will not lift a finger for its own crew, usually outlives a sinking through self-preserving spells, has no slave-market value because it escapes or dies rather than build for anyone else, and is an NPC villain only.', 'Rifts World Book 7: Underseas p.165-166');

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'all 1 creatures are in' AS assertion, count(*) AS got, 1 AS want
  FROM creatures WHERE slug IN ('ship-dreamers');
SELECT 'and 0 of them are playable' AS assertion, count(*) AS got, 0 AS want
  FROM creatures WHERE playable = 1 AND slug IN ('ship-dreamers');
SELECT 'the creatures carry 0 attacks' AS assertion, count(*) AS got, 0 AS want
  FROM stat_attacks WHERE owner_kind = 'creature' AND owner_slug IN ('ship-dreamers');

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~080-underseas-ship-dreamers.sql');
