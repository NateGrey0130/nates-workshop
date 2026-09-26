-- Rifts World Book 6: South America - the Loas as two creatures, not one.
--
-- One-off data script, run once per environment. It corrects a row
-- add-south-america-creatures.sql inserts, and sorts after it.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/fix-south-america-loas.sql
--
-- WHY. The book prints ONE stat block for the Loas with paired figures - "10
-- for ghostly loas or 12 for divine loas" (printed 53-54) - and the first
-- import stored one row, `loa`, holding the Ghostly Loa (90% of loas) with the
-- Divine Loa's figures in its notes. Nate asked for the Divine Loa as its own
-- row (2026-09-25). So:
--
--   * `loa` becomes `ghostly-loa`, "Ghostly Loa", its notes stripped of the
--     divine figures. No character or stat_attacks row referenced the slug.
--   * `divine-loa` is added: I.Q. 18, M.A. 17, M.E. 17, fly speed 33, P.P.E.
--     1D6+6, Horror Factor 12, its own skills and a god-set pair of psionic
--     powers. Everything else the book states once for both kinds (M.D.C.,
--     combat, bonuses, possession, habitat) is the same on both rows.
--
-- The Divine Loa's I.S.P. is printed as P.P.E. x10, which the roll grammar
-- cannot express (a pool may name only attributes), so `isp` is NULL and the
-- rule is in pools_note - the same treatment as the Ghostly Loa's P.E. x6.

UPDATE creatures SET
  slug = 'ghostly-loa',
  name = 'Ghostly Loa',
  pools_note = 'Its I.Q., M.A. and M.E. are those of the dead person it imprints on, so they are not stored; physical attributes do not apply in energy form. I.S.P. is printed as its P.E. x6, and it has no P.E. in energy form, so none is stored. Spd is hover/flight. A minor M.D.C. being on Rifts Earth; in S.D.C. settings, S.D.C. 1D4x10 and hit points 5D6 in energy form. Needs 40 P.P.E. a week. The Divine Loa is its own row.',
  bonuses_note = 'Attacks are psionic in energy form, physical or psionic in a host. Plus 3 to save vs magic and psionics, plus 10 vs Horror Factor; bonuses apply in both forms. Possession is resisted by a save vs psionics (a willing host does not save).',
  skills_note = 'Keeps whatever skills and languages its dead person had.',
  psionics = 'Two super psionic powers suited to the dead person (or one super plus two sensitive or healing powers), at 6th level mind melter strength.',
  description = 'The commoner of the two lesser spirits of Voodoo, about nine in ten loas: an entity that believes it is the spirit of a particular dead person and guards or torments the living accordingly. It possesses hosts to act in the physical world.'
WHERE slug = 'loa';

INSERT OR IGNORE INTO creatures (slug, name, category, system, playable, alignment, attributes, hp, sdc, mdc, ppe, isp, pools_note, ar, horror_factor, combat, bonuses_note, skills_note, natural_abilities, magic, psionics, size, weight, life_span, habitat, allies, enemies, occ_note, description, source_book) VALUES
('divine-loa', 'Divine Loa', 'spirit', 'rifts', 0, 'Any; most are good or selfish',
 '{"IQ":"18","MA":"17","ME":"17","PS":"N/A","PP":"N/A","PE":"N/A","PB":"N/A","Spd":"33"}',
 NULL, NULL, '1D4x10+40', '1D6+6', NULL,
 'I.S.P. is printed as P.P.E. x10, which the roll grammar cannot name, so none is stored: multiply the rolled P.P.E. by ten. Physical attributes do not apply in energy form. Spd is hover/flight. A minor M.D.C. being on Rifts Earth; in S.D.C. settings, S.D.C. 1D4x10 and hit points 5D6 in energy form. Needs 60 P.P.E. a week, and feeds only on P.P.E. from ceremonies, ley line nexuses, or what a Voodoo priest or its god gives it.',
 NULL, 12,
 '{"attacks":5,"initiative":2,"strike":2,"parry":4,"dodge":4,"roll":2,"pull":2}',
 'Attacks are psionic in energy form, physical or psionic in a host. Plus 3 to save vs magic and psionics, plus 10 vs Horror Factor; bonuses apply in both forms. Possession is resisted by a save vs psionics (a willing host does not save).',
 'Creole, French, Spanish and every African tongue at 98%; Voodoo Lore and Demon/Monster Lore 98%; Prowl 88%; tracking of animals and humans 76%; Wilderness Survival 72%; W.P. Blunt and W.P. Spear.',
 'Invisible, intangible energy being harmed only by magic and psionics; flies and passes through solid matter; can show itself as a vague winged humanoid; believes it is the life essence of a Voodoo god; possesses humans, D-Bees and animals (not supernatural beings), granting the host +2D4 P.S., +1D6 P.P., +2D4 P.E. and 100 bonus S.D.C. while it rides them.',
 'None',
 'Two sensitive or healing powers of choice, plus a pair set by the god it serves - Legba: Hydrokinesis, Mind Bond; Ertzuli: Empathic Transmission, Hypnotic Suggestion; Danbhala: Bio-Manipulation, Mind Bond; Chango: Pyrokinesis, Psi-Sword; Oggun: Telemechanics, Psi-Sword.',
 'Roughly 5 ft (1.5 m) in energy form', 'Not applicable', NULL,
 'Anywhere believers in Voodoo live: mostly South America and Africa''s west coast, some in North America',
 'Voodoo priests and believers, and the Voodoo god it serves',
 'Other entities and supernatural creatures',
 'Not for player characters (NPC only, per the book).',
 'The rarer of the two lesser spirits of Voodoo: an agent of one Voodoo god, fed only on ceremonial P.P.E., that visits or possesses priests and believers to warn, encourage or act for its god.',
 'Rifts World Book 6: South America p.53-54');

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'the Loas are two rows now' AS assertion, count(*) AS got, 2 AS want
  FROM creatures WHERE slug IN ('ghostly-loa', 'divine-loa');
SELECT 'and no row is still called loa' AS assertion, count(*) AS got, 0 AS want
  FROM creatures WHERE slug = 'loa';
SELECT 'the divine loa carries its own figures' AS assertion, count(*) AS got, 1 AS want
  FROM creatures WHERE slug = 'divine-loa' AND horror_factor = 12 AND ppe = '1D6+6' AND json_extract(attributes, '$.Spd') = '33';

INSERT INTO data_script_runs (filename) VALUES ('fix-south-america-loas.sql');
